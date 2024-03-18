resource "oci_identity_tag_namespace" "this" {
  compartment_id = var.tenancy
  description    = "Siliconsheep"
  name           = "Siliconsheep"

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "oci_identity_tag" "service" {
  description      = "Service"
  name             = "Service"
  tag_namespace_id = oci_identity_tag_namespace.this.id

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "oci_identity_tag" "cluster" {
  description      = "Cluster"
  name             = "Cluster"
  tag_namespace_id = oci_identity_tag_namespace.this.id

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "oci_identity_tag" "component" {
  description      = "Component"
  name             = "Component"
  tag_namespace_id = oci_identity_tag_namespace.this.id

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
}
