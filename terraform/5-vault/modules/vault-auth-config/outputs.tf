output "mount_path" {
  value = local.vault_mount_path
}

output "kubernetes_host" {
  value = local.kubernetes_host
}

output "kubernetes_ca_cert" {
  value = local.kubernetes_ca_cert
}

output "token_reviewer_jwt" {
  value = local.token_reviewer_jwt
}
