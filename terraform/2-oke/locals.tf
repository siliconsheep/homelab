locals {
  secrets = yamldecode(file("/secrets.yaml"))

  defined_tags = {
    "Siliconsheep-Tags.Layer" = "OKE"
  }

  kubernetes_version = "1.24.1"

  protocol_ICMP = "1"
  protocol_TCP  = "6"
  protocol_UDP  = "17"

  vcn_ocid            = data.oci_core_vcns.this.virtual_networks[0].id
  private_subnet_ocid = data.oci_core_subnets.private_subnets.subnets[0].id
  public_subnet_ocid  = data.oci_core_subnets.public_subnets.subnets[0].id

  parsed_oke_images = {
    for source in data.oci_containerengine_node_pool_option.all_node_pool_options.sources : source.image_id =>
    flatten(regexall("Oracle-Linux-8.6-aarch64-([^-]+)-\\d+-OKE-${local.kubernetes_version}", source.source_name)) if source.source_type == "IMAGE"
  }
  most_recent_date  = reverse(sort(flatten(values(local.parsed_oke_images))))[0]
  correct_oke_image = [for image_id, date in local.parsed_oke_images : image_id if date == [local.most_recent_date]][0]
}
