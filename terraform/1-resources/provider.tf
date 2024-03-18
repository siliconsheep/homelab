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

    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.25"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.11.0"
    }
  }
}

provider "oci" {
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}

provider "scaleway" {}

provider "cloudflare" {}

provider "vault" {}
