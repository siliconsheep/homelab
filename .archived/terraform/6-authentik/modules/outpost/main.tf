resource "authentik_service_connection_kubernetes" "this" {
  name = "kubernetes-${var.name}"
  kubeconfig = var.local_connection ? "{}" : jsonencode(yamldecode(templatefile("${path.module}/templates/kubeconfig.yml.tpl", {
    server    = local.kubernetes_host
    ca        = local.kubernetes_ca_cert
    token     = local.token
    namespace = var.secret_namespace
  })))
  local = var.local_connection
}

resource "authentik_outpost" "this" {
  name               = var.name
  type               = "proxy"
  service_connection = authentik_service_connection_kubernetes.this.id

  protocol_providers = var.protocol_providers
}
