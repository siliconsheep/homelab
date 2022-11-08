resource "oci_identity_tag_namespace" "siliconsheep_namespace" {
  compartment_id = var.compartment_ocid
  description    = "Siliconsheep Tag Namespace"
  name           = "Siliconsheep-Tags"

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "oci_identity_tag" "layer" {
  description      = "Layer tag"
  name             = "Layer"
  tag_namespace_id = oci_identity_tag_namespace.siliconsheep_namespace.id

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
}
