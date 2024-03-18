resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = local.vault_mount_path
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = local.kubernetes_host
  kubernetes_ca_cert = base64decode(local.kubernetes_ca_cert)
  token_reviewer_jwt = local.token_reviewer_jwt
}
