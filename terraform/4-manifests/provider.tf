terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4.98"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.28.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.15"
    }
  }
}

provider "oci" {
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}

provider "cloudflare" {}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    # args        = ["ce", "cluster", "generate-token", "--cluster-id", data.oci_containerengine_clusters.this.clusters[0].id]
    args = local.oci_args
  }
}
