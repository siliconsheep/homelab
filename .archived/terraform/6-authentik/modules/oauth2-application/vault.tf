resource "vault_kv_secret_v2" "oauth_config" {
  mount               = "/secret"
  name                = "/auth/oauth-credentials/${authentik_application.this.slug}"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      application_slug = authentik_application.this.slug,
      client_id        = authentik_provider_oauth2.this.client_id,
      client_secret    = authentik_provider_oauth2.this.client_secret,
    }
  )
}
