resource "oci_core_security_list" "public-security-list" {
  vcn_id         = oci_core_vcn.default.id
  compartment_id = var.compartment_ocid

  display_name = "Security List for Public subet"

  ingress_security_rules {
    description = "VyOS - Allow SSH"
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
    description = "VyOS - Allow ICMP"
    protocol    = local.protocol_ICMP

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Common - Allow all traffic from private subnet"
    protocol    = "all"

    source      = local.secrets.private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Common - Allow all traffic from internal LAN"
    protocol    = "all"

    source      = local.secrets.internal_lan_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    protocol  = "all"
    stateless = "false"
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

  ingress_security_rules {
    description = "K8S - Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"

    source      = local.secrets.private_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "K8S - Path discovery"
    protocol    = local.protocol_ICMP

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "K8S - Allow Kubernetes control plane and Load Balancers to communicate with worker nodes"
    protocol    = "all"

    source      = local.secrets.public_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "K8S - Allow inbound SSH traffic to worker nodes"
    protocol    = local.protocol_TCP

    source      = local.secrets.internal_lan_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    protocol  = "all"
    stateless = "false"
  }

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}
