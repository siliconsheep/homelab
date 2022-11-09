terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4.98"
    }

    namedotcom = {
      source  = "lexfrei/namedotcom"
      version = "~> 1.2"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

provider "namedotcom" {
  username = var.namedotcom_username
  token    = var.namedotcom_token
}
