resource "kubernetes_namespace_v1" "networking" {
  metadata {
    name = "networking"
  }
}

resource "kubernetes_secret_v1" "cf-token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = kubernetes_namespace_v1.networking.metadata[0].name
  }

  data = {
    "api-token" = cloudflare_api_token.cert-manager.value
  }
}

resource "kubernetes_namespace_v1" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_secret_v1" "vault" {
  metadata {
    name      = "vault-oci-kms"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }

  data = {
    "kms_key_id"          = local.kms_key.id
    "crypto_endpoint"     = local.vault.crypto_endpoint
    "management_endpoint" = local.vault.management_endpoint
  }
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_config_map_v1" "infra-vars" {
  metadata {
    name      = "infra-vars"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }

  data = {
    "values-prometheus.yaml" = yamlencode({
      "kube-prometheus-stack" = {
        "prometheus" = {
          "service" = {
            "annotations" = {
              "oci.oraclecloud.com/load-balancer-type" : "nlb"
              "oci-network-load-balancer.oraclecloud.com/internal" : "true"
              "oci-network-load-balancer.oraclecloud.com/subnet" : data.oci_core_subnets.private_subnet.subnets[0].id
            }
          }
        }
      }
    }),
    "values-cluster-autoscaler.yaml" = yamlencode({
      "cluster-autoscaler" = {
        "autoscalingGroups" = [for node_pool in data.oci_containerengine_node_pools.this.node_pools : {
          "name"    = node_pool.id
          "minSize" = parseint(node_pool.freeform_tags["Cluster-Autoscaler-Min-Size"], 10)
          "maxSize" = parseint(node_pool.freeform_tags["Cluster-Autoscaler-Max-Size"], 10)
        }]
        "expanderPriorities" = { for node_pool in data.oci_containerengine_node_pools.this.node_pools :
          parseint(node_pool.freeform_tags["Cluster-Autoscaler-Priority"], 10) => [node_pool.id]
        }
      }
    })
  }
}
