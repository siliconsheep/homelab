resource "oci_kms_vault" "vault" {
  compartment_id = var.tenancy
  display_name   = "Vault"
  vault_type     = "DEFAULT"

  defined_tags = merge(local.defined_tags, { "Siliconsheep.Service" = "Vault" })
}

resource "oci_kms_key" "vault-kms" {
  compartment_id = var.tenancy
  display_name   = "Vault KMS key"

  key_shape {
    algorithm = "AES"
    length    = "24"
  }

  management_endpoint = oci_kms_vault.vault.management_endpoint

  defined_tags    = merge(local.defined_tags, { "Siliconsheep.Service" = "Vault" })
  protection_mode = "SOFTWARE"
}
