data "oci_identity_compartment" "this" {
  id = var.tenancy
}

data "oci_core_vcns" "this" {
  compartment_id = var.tenancy
  display_name   = "Primary VCN"
}

data "oci_core_subnets" "private_subnets" {
  compartment_id = var.tenancy
  display_name   = "Private subnet"
  vcn_id         = local.vcn_ocid
}

data "oci_core_subnets" "public_subnets" {
  compartment_id = var.tenancy
  display_name   = "Public subnet"
  vcn_id         = local.vcn_ocid
}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy
}

data "oci_containerengine_node_pool_option" "all_node_pool_options" {
  compartment_id      = var.tenancy
  node_pool_option_id = "all"
}
