resource "oci_core_vcn" "default" {
  compartment_id = var.tenancy
  cidr_block     = local.secrets.vcn_cidr_block
  display_name   = "Primary VCN"
  dns_label      = "vcn1"

  defined_tags = local.defined_tags
}

resource "oci_core_route_table" "private-route-table" {
  vcn_id         = oci_core_vcn.default.id
  compartment_id = var.tenancy

  display_name = "Private route table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.vyos.private_ips[0].id
  }

  defined_tags = local.defined_tags
}

resource "oci_core_subnet" "private-subnet" {
  cidr_block                 = local.secrets.private_subnet_cidr_block
  compartment_id             = var.tenancy
  display_name               = "Private subnet"
  dns_label                  = "private"
  vcn_id                     = oci_core_vcn.default.id
  prohibit_public_ip_on_vnic = true
  prohibit_internet_ingress  = true

  route_table_id = oci_core_route_table.private-route-table.id

  security_list_ids = [
    oci_core_security_list.private-security-list.id,
  ]

  defined_tags = local.defined_tags
}

resource "oci_core_internet_gateway" "default" {
  compartment_id = var.tenancy
  display_name   = "IGW for public subnet"
  enabled        = "true"
  vcn_id         = oci_core_vcn.default.id

  defined_tags = local.defined_tags
}

resource "oci_core_route_table" "public-route-table" {
  vcn_id         = oci_core_vcn.default.id
  compartment_id = var.tenancy

  display_name = "Public route table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.default.id
  }

  defined_tags = local.defined_tags
}

resource "oci_core_subnet" "public-subnet" {
  cidr_block     = local.secrets.public_subnet_cidr_block
  compartment_id = var.tenancy
  display_name   = "Public subnet"
  dns_label      = "public"
  vcn_id         = oci_core_vcn.default.id

  route_table_id = oci_core_route_table.public-route-table.id

  security_list_ids = [
    oci_core_security_list.public-security-list.id,
  ]

  defined_tags = local.defined_tags
}
