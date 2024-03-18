resource "cloudflare_record" "vyos-siliconsheep-se" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "A"
  name    = "vyos"
  value   = oci_core_instance.vyos_instance.public_ip
  proxied = false
  ttl     = 300
}
