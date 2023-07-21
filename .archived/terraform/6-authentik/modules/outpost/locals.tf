locals {
  kubeconfig = var.local_connection ? null : yamldecode(file(var.kube_config_path))
  cluster    = var.local_connection ? "" : [for context in local.kubeconfig["contexts"] : context if context["name"] == var.kube_context][0]["context"]["cluster"]

  kubernetes_host    = var.local_connection ? "" : [for cluster in local.kubeconfig["clusters"] : cluster if cluster["name"] == local.cluster][0]["cluster"]["server"]
  kubernetes_ca_cert = var.local_connection ? "" : [for cluster in local.kubeconfig["clusters"] : cluster if cluster["name"] == local.cluster][0]["cluster"]["certificate-authority-data"]
  token              = var.local_connection ? "" : data.kubernetes_secret_v1.this[0].data["token"]
}
