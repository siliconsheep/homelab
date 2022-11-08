locals {
  secrets = yamldecode(file("/secrets.yaml"))

  defined_tags = {
    "Siliconsheep-Tags.Layer" = "Network"
  }

  protocol_ICMP = "1"
  protocol_TCP  = "6"
  protocol_UDP  = "17"

  vyos_ip = cidrhost(local.secrets.public_subnet_cidr_block, 2)
}
