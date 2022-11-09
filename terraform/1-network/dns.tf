resource "namedotcom_record" "vyos_dns_name" {
  domain_name = "siliconsheep.se"
  host        = "vyos"
  record_type = "A"
  answer      = oci_core_instance.vyos_instance.public_ip
}
