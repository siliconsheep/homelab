resource "oci_core_network_security_group" "k8s-cluster-nsg" {
  compartment_id = var.tenancy
  vcn_id         = local.vcn_ocid
  display_name   = "NSG for VyOS"

  defined_tags = local.defined_tags
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
  compartment_id     = var.tenancy
  kubernetes_version = "v${local.master_kubernetes_version}"
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

data "cloudinit_config" "k8s-node-pool-cloud-init-arm64" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "install_oci.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/templates/install_oci.sh")
  }

  part {
    filename     = "node_init_arm64.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/templates/node_init_arm64.sh")
  }
}

data "cloudinit_config" "k8s-node-pool-cloud-init-amd64" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "node_init_amd64.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/templates/node_init_amd64.sh")
  }
}

resource "oci_containerengine_node_pool" "k8s-node-pool-arm64-standard" {
  cluster_id         = oci_containerengine_cluster.k8s-cluster.id
  compartment_id     = var.tenancy
  kubernetes_version = "v${local.node_kubernetes_version}"
  name               = "siliconsheep-np-arm64-standard"

  node_shape = "VM.Standard.A1.Flex"
  node_metadata = {
    user_data = data.cloudinit_config.k8s-node-pool-cloud-init-arm64.rendered
  }

  node_config_details {
    dynamic "placement_configs" {
      for_each = toset(data.oci_identity_availability_domains.this.availability_domains)

      content {
        availability_domain = placement_configs.key.name
        subnet_id           = local.private_subnet_ocid
      }
    }

    size = 0

    defined_tags = local.defined_tags
  }

  node_shape_config {
    memory_in_gbs = 8
    ocpus         = 1
  }

  node_source_details {
    image_id    = local.oke_image_aarch64
    source_type = "image"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/location"
    value = "oci"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/node-pool-type"
    value = "arm64-standard"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/system-workloads"
    value = "true"
  }

  ssh_public_key = local.secrets.ssh_public_key

  freeform_tags = {
    "Cluster-Autoscaler-Min-Size" = "0"
    "Cluster-Autoscaler-Max-Size" = "0"
    "Cluster-Autoscaler-Priority" = "10"
  }

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [
      node_config_details[0].size
    ]
  }
}

resource "oci_containerengine_node_pool" "k8s-node-pool-arm64-high-cpu" {
  cluster_id         = oci_containerengine_cluster.k8s-cluster.id
  compartment_id     = var.tenancy
  kubernetes_version = "v${local.node_kubernetes_version}"
  name               = "siliconsheep-np-arm64-high-cpu"

  node_shape = "VM.Standard.A1.Flex"
  node_metadata = {
    user_data = data.cloudinit_config.k8s-node-pool-cloud-init-arm64.rendered
  }

  node_config_details {
    dynamic "placement_configs" {
      for_each = toset(data.oci_identity_availability_domains.this.availability_domains)

      content {
        availability_domain = placement_configs.key.name
        subnet_id           = local.private_subnet_ocid
      }
    }

    size = 3

    defined_tags = local.defined_tags
  }

  node_shape_config {
    memory_in_gbs = 8
    ocpus         = 2
  }

  node_source_details {
    image_id    = local.oke_image_aarch64
    source_type = "image"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/location"
    value = "oci"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/node-pool-type"
    value = "arm64-high-cpu"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/system-workloads"
    value = "false"
  }

  ssh_public_key = local.secrets.ssh_public_key

  freeform_tags = {
    "Cluster-Autoscaler-Min-Size" = "2"
    "Cluster-Autoscaler-Max-Size" = "3"
    "Cluster-Autoscaler-Priority" = "30"
  }

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [
      node_config_details[0].size
    ]
  }
}

resource "oci_containerengine_node_pool" "k8s-node-pool-amd64-standard" {
  cluster_id         = oci_containerengine_cluster.k8s-cluster.id
  compartment_id     = var.tenancy
  kubernetes_version = "v${local.node_kubernetes_version}"
  name               = "siliconsheep-np-amd64-standard"

  node_shape = "VM.Standard.E4.Flex"

  node_metadata = {
    user_data = data.cloudinit_config.k8s-node-pool-cloud-init-amd64.rendered
  }

  node_config_details {
    dynamic "placement_configs" {
      for_each = toset(data.oci_identity_availability_domains.this.availability_domains)

      content {
        availability_domain = placement_configs.key.name
        subnet_id           = local.private_subnet_ocid
      }
    }

    size = 0

    defined_tags = local.defined_tags
  }

  node_shape_config {
    memory_in_gbs = 8
    ocpus         = 1
  }

  node_source_details {
    image_id    = local.oke_image_amd64
    source_type = "image"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/location"
    value = "oci"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/node-pool-type"
    value = "amd64-standard"
  }

  initial_node_labels {
    key   = "k8s.siliconsheep.se/system-workloads"
    value = "false"
  }

  ssh_public_key = local.secrets.ssh_public_key

  freeform_tags = {
    "Cluster-Autoscaler-Min-Size" = "0"
    "Cluster-Autoscaler-Max-Size" = "1"
    "Cluster-Autoscaler-Priority" = "20"
  }

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [
      node_config_details[0].size
    ]
  }
}
