resource "oci_objectstorage_bucket" "vault-backend" {
  compartment_id = var.tenancy
  name           = "vault-backend"
  namespace      = data.oci_objectstorage_namespace.this.namespace

  defined_tags = merge(local.defined_tags, {
    "Siliconsheep.Service" = "Vault",
  })
}

resource "oci_objectstorage_bucket" "vault-backend-lock" {
  compartment_id = var.tenancy
  name           = "vault-backend-lock"
  namespace      = data.oci_objectstorage_namespace.this.namespace

  defined_tags = merge(local.defined_tags, {
    "Siliconsheep.Service" = "Vault",
  })
}

resource "oci_objectstorage_bucket" "assets" {
  compartment_id = var.tenancy
  name           = "siliconsheep-assets"
  namespace      = data.oci_objectstorage_namespace.this.namespace

  access_type = "ObjectRead"

  defined_tags = merge(local.defined_tags, {
    "Siliconsheep.Service" = "Assets",
  })
}

resource "scaleway_object_bucket" "longhorn" {
  name       = "siliconsheep-longhorn"
  project_id = data.scaleway_account_project.homelab.id

  lifecycle_rule {
    id      = "move-backups-to-ia"
    enabled = true

    transition {
      days          = 1
      storage_class = "ONEZONE_IA"
    }
  }

  force_destroy = true

  tags = merge(local.defined_tags, {
    "Siliconsheep.Service" = "Longhorn",
  })
}

resource "scaleway_object_bucket" "velero-backups" {
  name       = "siliconsheep-velero-backups"
  project_id = data.scaleway_account_project.homelab.id

  lifecycle_rule {
    id      = "move-backups-to-ia"
    enabled = true

    transition {
      days          = 1
      storage_class = "ONEZONE_IA"
    }
  }

  force_destroy = true

  tags = merge(local.defined_tags, {
    "Siliconsheep.Service" = "Velero",
  })
}
