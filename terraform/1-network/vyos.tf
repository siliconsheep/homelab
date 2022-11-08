resource "oci_core_network_security_group" "vyos_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.default.id
  display_name   = "NSG for VyOS"

  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "oci_core_network_security_group_security_rule" "vyos_allow_wg" {
  network_security_group_id = oci_core_network_security_group.vyos_nsg.id
  direction                 = "INGRESS"
  protocol                  = local.protocol_UDP
  description               = "Allow incoming WireGuard traffic"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      max = 51820
      min = 51820
    }
  }
}

resource "oci_core_instance" "vyos_instance" {
  compartment_id       = var.compartment_ocid
  display_name         = "VyOS instance"
  availability_domain  = data.oci_identity_availability_domains.this.availability_domains[0].name
  shape                = "VM.Standard.E2.1.Micro"
  preserve_boot_volume = false

  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  create_vnic_details {
    assign_public_ip       = true
    defined_tags           = local.defined_tags
    display_name           = "Primary VNIC for VyOS"
    hostname_label         = "vyos"
    nsg_ids                = [oci_core_network_security_group.vyos_nsg.id]
    private_ip             = local.vyos_ip
    skip_source_dest_check = true
    subnet_id              = oci_core_subnet.public-subnet.id
  }

  metadata = {
    ssh_authorized_keys = local.secrets.ssh_public_key
    user_data = base64gzip(templatefile("${path.module}/templates/userdata.tpl", {
      wireguard_public_key  = local.secrets.wireguard["public_key"]
      wireguard_private_key = local.secrets.wireguard["private_key"]
      vyos_commands         = local.secrets.vyos_commands
    }))
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.vyos-images.images[0].id
  }


  defined_tags = local.defined_tags

  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }

  timeouts {
    create = "30m"
  }
}

resource "null_resource" "ping_vyos" {

  depends_on = [
    oci_core_instance.vyos_instance
  ]

  provisioner "local-exec" {
    command = "until ping -c1 ${oci_core_instance.vyos_instance.public_ip} >/dev/null 2>&1; do sleep 2; done"
  }
}
