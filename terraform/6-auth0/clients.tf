module "dhome" {
  source = "./modules/auth0-client"

  name        = "dHome"
  app_type    = "regular_web"
  description = "OAuth2 Proxy for dHome"
  logo_uri    = "https://github.com/oauth2-proxy/oauth2-proxy/raw/master/docs/static/img/logos/OAuth2_Proxy_horizontal.svg"

  oidc_conformant = true

  allowed_logout_urls = [
    "https://*.siliconsheep.se"
  ]
  allowed_origins = []
  callbacks = [
    "https://auth2.siliconsheep.se/oauth2/callback"
  ]

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
    "client_credentials",
  ]
}

module "dhome_oke" {
  source = "./modules/auth0-client"

  name        = "dHome - OCI"
  app_type    = "regular_web"
  description = "OAuth2 Proxy for dHome (OCI)"
  logo_uri    = "https://github.com/oauth2-proxy/oauth2-proxy/raw/master/docs/static/img/logos/OAuth2_Proxy_horizontal.svg"

  oidc_conformant = true

  allowed_logout_urls = [
    "https://*.siliconsheep.se"
  ]
  allowed_origins = []
  callbacks = [
    "https://auth.siliconsheep.se/oauth2/callback"
  ]

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
    "client_credentials",
  ]
}

module "argocd" {
  source = "./modules/auth0-client"

  name        = "ArgoCD"
  app_type    = "spa"
  description = "ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes."
  logo_uri    = "https://argo-cd.readthedocs.io/en/stable/assets/logo.png"

  initiate_login_uri = "https://argocd.siliconsheep.se"
  oidc_conformant    = true

  allowed_origins = [
    "https://argocd.siliconsheep.se"
  ]
  callbacks = [
    "https://argocd.siliconsheep.se/api/dex/callback"
  ]

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
  ]
}

module "grafana" {
  source = "./modules/auth0-client"

  name        = "Grafana"
  app_type    = "regular_web"
  description = "Grafana is the open source analytics and monitoring solution for every database"
  logo_uri    = "https://grafana.com/static/img/about/grafana_logo_swirl_fullcolor.jpg"

  oidc_conformant = true

  allowed_origins = [
    "https://grafana.siliconsheep.se"
  ]

  callbacks = [
    "https://grafana.siliconsheep.se/login/generic_oauth"
  ]

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
  ]
}

module "vault" {
  source = "./modules/auth0-client"

  name        = "Vault"
  app_type    = "regular_web"
  description = "Vault is a tool for securely accessing secrets."
  logo_uri    = "https://www.hashicorp.com/_next/static/media/colorwhite.c5723175.svg"

  initiate_login_uri = "https://vault.siliconsheep.se"
  oidc_conformant    = true

  allowed_origins = [
    "https://vault.siliconsheep.se",
    "http://localhost:8250"
  ]
  callbacks = [
    "https://vault.siliconsheep.se/ui/vault/auth/oidc/auth0/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]

  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token",
  ]
}

module "auth0_actions_client" {
  source = "./modules/auth0-client"

  name        = "Auth0 Actions Client"
  app_type    = "non_interactive"
  description = "Internal client used by Actions to call the management API."

  api_grants = {
    "https://${data.auth0_tenant.this.domain}/api/v2/" = [
      "read:users",
      "update:users",
      "read:users_app_metadata",
      "update:users_app_metadata"
    ]
  }
}
