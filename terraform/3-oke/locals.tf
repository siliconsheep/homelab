locals {
  secrets = yamldecode(file("/secrets.yaml"))

  defined_tags = {
    "Siliconsheep.Service" = "OKE"
    "Siliconsheep.Cluster" = "siliconsheep-oke"
  }

  master_kubernetes_version = "1.28.2"
  node_kubernetes_version   = "1.28.2"

  protocol_ICMP = "1"
  protocol_TCP  = "6"
  protocol_UDP  = "17"

  vcn_ocid            = data.oci_core_vcns.this.virtual_networks[0].id
  private_subnet_ocid = data.oci_core_subnets.private_subnets.subnets[0].id
  public_subnet_ocid  = data.oci_core_subnets.public_subnets.subnets[0].id

  parsed_oke_images_aarch64 = {
    for source in data.oci_containerengine_node_pool_option.all_node_pool_options.sources : source.image_id =>
    flatten(regexall("Oracle-Linux-8.9-aarch64-([^-]+)-\\d+-OKE-${local.node_kubernetes_version}", source.source_name)) if source.source_type == "IMAGE"
  }
  most_recent_date_aarch64 = reverse(sort(flatten(values(local.parsed_oke_images_aarch64))))[0]

  oke_image_aarch64 = [for image_id, date in local.parsed_oke_images_aarch64 : image_id if date == [local.most_recent_date_aarch64]][0]

  parsed_oke_images_amd64 = {
    for source in data.oci_containerengine_node_pool_option.all_node_pool_options.sources : source.image_id =>
    flatten(regexall("Oracle-Linux-8.9-([^-]+)-\\d+-OKE-${local.node_kubernetes_version}", source.source_name)) if source.source_type == "IMAGE"
  }
  most_recent_date_amd64 = reverse(sort(flatten(values(local.parsed_oke_images_amd64))))[0]

  oke_image_amd64 = [for image_id, date in local.parsed_oke_images_amd64 : image_id if date == [local.most_recent_date_amd64]][0]
}
