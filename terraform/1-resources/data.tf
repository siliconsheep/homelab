data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy
}

data "cloudflare_zone" "siliconsheep-se" {
  name = "siliconsheep.se"
}

data "scaleway_account_project" "homelab" {
  name = "homelab"
}
