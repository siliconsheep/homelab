resource "oci_core_network_security_group" "k8s-cluster-nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = local.vcn_ocid
  display_name   = "NSG for VyOS"

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_network_security_group_security_rule" "k8s-cluster-allow-node-pools-6443" {
  network_security_group_id = oci_core_network_security_group.k8s-cluster-nsg.id
  direction                 = "INGRESS"
  protocol                  = local.protocol_TCP
  description               = "Allow Kubernetes node pools (API)"

  source      = local.secrets.private_subnet_cidr_block
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "k8s-cluster-allow-node-pools-12250" {
  network_security_group_id = oci_core_network_security_group.k8s-cluster-nsg.id
  direction                 = "INGRESS"
  protocol                  = local.protocol_TCP
  description               = "Allow Kubernetes node pools (control plane)"

  source      = local.secrets.private_subnet_cidr_block
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 12250
      min = 12250
    }
  }
}

resource "oci_core_network_security_group_security_rule" "k8s-cluster-allow-lan" {
  network_security_group_id = oci_core_network_security_group.k8s-cluster-nsg.id
  direction                 = "INGRESS"
  protocol                  = local.protocol_TCP
  description               = "Allow internal LAN traffic"

  source      = local.secrets.internal_lan_cidr_block
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_containerengine_cluster" "k8s-cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = "v${local.kubernetes_version}"
  name               = "siliconsheep-oke"
  vcn_id             = local.vcn_ocid

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = local.private_subnet_ocid
    nsg_ids              = [oci_core_network_security_group.k8s-cluster-nsg.id]
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.128.0.0/16"
      services_cidr = "10.28.0.0/16"
    }

    persistent_volume_config {
      defined_tags = local.defined_tags
    }

    service_lb_config {
      defined_tags = local.defined_tags
    }

    service_lb_subnet_ids = [local.public_subnet_ocid]
  }

  defined_tags = local.defined_tags
}

resource "oci_containerengine_node_pool" "k8s-node-pool" {
  cluster_id         = oci_containerengine_cluster.k8s-cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = "v${local.kubernetes_version}"
  name               = "siliconsheep-oke-node-pool"

  node_shape = "VM.Standard.A1.Flex"

  node_config_details {
    dynamic "placement_configs" {
      for_each = toset(data.oci_identity_availability_domains.this.availability_domains)

      content {
        availability_domain = placement_configs.key.name
        subnet_id           = local.private_subnet_ocid
      }
    }

    size = 3
  }

  node_shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  node_source_details {
    image_id    = local.correct_oke_image
    source_type = "image"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/location"
    value = "oci"
  }

  ssh_public_key = local.secrets.ssh_public_key
}
