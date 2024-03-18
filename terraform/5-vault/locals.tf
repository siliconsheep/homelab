locals {
  secrets = yamldecode(file("/secrets.yaml"))
  kubernetes_auth_mount_paths = {
    home = module.vault-kubernetes-auth-home.mount_path
    oke  = module.vault-kubernetes-auth-oke.mount_path
  }
}
