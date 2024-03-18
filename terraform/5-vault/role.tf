resource "vault_kubernetes_auth_backend_role" "this" {
  for_each = fileset(path.module, "roles/*/*.yaml")

  backend                          = local.kubernetes_auth_mount_paths[basename(dirname(each.key))]
  role_name                        = trimsuffix(basename(each.key), ".yaml")
  bound_service_account_names      = lookup(yamldecode(file(each.key)), "bound_service_account_names", ["*"])
  bound_service_account_namespaces = lookup(yamldecode(file(each.key)), "bound_service_account_namespaces", ["*"])

  token_ttl      = lookup(yamldecode(file(each.key)), "token_ttl", 3600)
  token_policies = lookup(yamldecode(file(each.key)), "token_policies", [])
}
