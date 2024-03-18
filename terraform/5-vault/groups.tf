resource "vault_identity_group" "admins" {
  name     = "admins"
  type     = "external"
  policies = ["admin"]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group_alias" "auth0_admins" {
  name           = "vault-admins"
  mount_accessor = vault_jwt_auth_backend.auth0.accessor
  canonical_id   = vault_identity_group.admins.id
}
