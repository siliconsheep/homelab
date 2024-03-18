data "oci_containerengine_clusters" "this" {
  compartment_id = var.tenancy
  name           = "siliconsheep-oke"
}

data "oci_containerengine_node_pools" "this" {
  compartment_id = var.tenancy
  cluster_id     = data.oci_containerengine_clusters.this.clusters[0].id
}

data "oci_containerengine_cluster_kube_config" "this" {
  cluster_id    = data.oci_containerengine_clusters.this.clusters[0].id
  endpoint      = "PRIVATE_ENDPOINT"
  token_version = "2.0.0"
}

data "cloudflare_api_token_permission_groups" "all" {}

data "oci_kms_vaults" "this" {
  compartment_id = var.tenancy
}

data "oci_kms_keys" "this" {
  compartment_id      = var.tenancy
  management_endpoint = local.vault.management_endpoint
}

data "oci_core_subnets" "private_subnet" {
  compartment_id = var.tenancy
  display_name   = "Private subnet"
}
