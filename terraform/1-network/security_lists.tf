resource "oci_core_security_list" "public-security-list" {
  vcn_id         = oci_core_vcn.default.id
  compartment_id = var.compartment_ocid

  display_name = "Security List for Public subet"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    protocol  = "all"
    stateless = "false"
  }

  ingress_security_rules {
    description = "SSH"
    protocol    = local.protocol_TCP

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    description = "Allow ICMP"
    protocol    = local.protocol_ICMP

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Allow private -> public subnet traffic"
    protocol    = "all"

    source      = local.secrets.private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Allow internal LAN -> public subnet traffic"
    protocol    = "all"

    source      = local.secrets.internal_lan_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_security_list" "private-security-list" {
  vcn_id         = oci_core_vcn.default.id
  compartment_id = var.compartment_ocid

  display_name = "Security List for Private subet"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    protocol  = "all"
    stateless = "false"
  }

  ingress_security_rules {
    description = "SSH"
    protocol    = local.protocol_TCP

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    description = "Allow ICMP"
    protocol    = local.protocol_ICMP

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Allow public -> private subnet traffic"
    protocol    = "all"

    source      = local.secrets.public_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Allow internal LAN -> private subnet traffic"
    protocol    = "all"

    source      = local.secrets.internal_lan_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
