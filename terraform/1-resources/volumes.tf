# No longer needed
# resource "oci_core_volume" "longhorn-data-volume" {
#   count = 3

#   compartment_id      = var.tenancy
#   availability_domain = data.oci_identity_availability_domains.this.availability_domains[count.index % length(data.oci_identity_availability_domains.this.availability_domains)].name
#   defined_tags        = merge(local.defined_tags, { "Siliconsheep.Service" = "Longhorn" })
#   display_name        = "longhorn-data-${count.index}"
#   size_in_gbs         = "50"
#   vpus_per_gb         = 10
# }
