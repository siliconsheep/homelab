locals {
  kubeconfig             = yamldecode(data.oci_containerengine_cluster_kube_config.this.content)
  cluster_endpoint       = local.kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  oci_args               = local.kubeconfig["users"][0]["user"]["exec"]["args"]

  vault   = [for v in data.oci_kms_vaults.this.vaults : v if lookup(v.defined_tags, "Siliconsheep.Service", "") == "Vault"][0]
  kms_key = [for k in data.oci_kms_keys.this.keys : k if lookup(k.defined_tags, "Siliconsheep.Service", "") == "Vault"][0]
}
