locals {
  kubeconfig = yamldecode(file(var.kube_config_path))
  cluster    = [for context in local.kubeconfig["contexts"] : context if context["name"] == var.kube_context][0]["context"]["cluster"]

  kubernetes_host    = [for cluster in local.kubeconfig["clusters"] : cluster if cluster["name"] == local.cluster][0]["cluster"]["server"]
  kubernetes_ca_cert = [for cluster in local.kubeconfig["clusters"] : cluster if cluster["name"] == local.cluster][0]["cluster"]["certificate-authority-data"]
  token_reviewer_jwt = data.kubernetes_secret_v1.this.data["token"]

  vault_mount_path = var.vault_mount_path == "" ? "kubernetes/${var.kube_context}" : var.vault_mount_path
}
