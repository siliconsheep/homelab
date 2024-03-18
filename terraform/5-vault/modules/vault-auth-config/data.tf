data "kubernetes_secret_v1" "this" {
  metadata {
    name      = var.secret_name
    namespace = var.secret_namespace
  }
}
