data "oci_core_vcns" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "Primary VCN"
}

data "oci_core_subnets" "private_subnets" {
  compartment_id = var.compartment_ocid
  display_name   = "Private subnet"
  vcn_id         = local.vcn_ocid
}

data "oci_core_subnets" "public_subnets" {
  compartment_id = var.compartment_ocid
  display_name   = "Public subnet"
  vcn_id         = local.vcn_ocid
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_ocid
}

data "oci_containerengine_node_pool_option" "all_node_pool_options" {
  compartment_id      = var.compartment_ocid
  node_pool_option_id = "all"
}
