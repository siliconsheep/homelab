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

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "oci" {
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}

provider "cloudflare" {}
