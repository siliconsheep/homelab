data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "vyos-images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "VyOS"
  operating_system_version = "1.3"

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

data "oci_core_private_ips" "vyos" {
  ip_address = oci_core_instance.vyos_instance.private_ip
  subnet_id  = oci_core_subnet.public-subnet.id

  depends_on = [
    null_resource.ping_vyos
  ]
}
