resource "vault_kv_secret_v2" "oauth_config" {
  mount               = "/secret"
  name                = "/auth/oauth-credentials/${replace(lower(auth0_client.this.name), "/[\\s_-]+/", "-")}"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      domain        = "https://${data.auth0_tenant.this.domain}/",
      client-id     = auth0_client.this.id,
      client-secret = auth0_client_credentials.this.client_secret,
    }
  )
}
