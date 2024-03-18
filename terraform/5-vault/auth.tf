module "vault-kubernetes-auth-home" {
  source = "./modules/vault-auth-config"
  providers = {
    vault      = vault
    kubernetes = kubernetes.siliconsheep-home
  }

  kube_config_path = var.kube_config_path
  kube_context     = "siliconsheep-home"
  secret_name      = "vault-home-service-account-token"
  secret_namespace = "vault"
  vault_mount_path = "kubernetes/home"
}

module "vault-kubernetes-auth-oke" {
  source = "./modules/vault-auth-config"
  providers = {
    vault      = vault
    kubernetes = kubernetes.siliconsheep-oke
  }

  kube_config_path = var.kube_config_path
  kube_context     = "siliconsheep-oke"
  secret_name      = "vault-oke-service-account-token"
  secret_namespace = "vault"
  vault_mount_path = "kubernetes/oke"
}

resource "vault_jwt_auth_backend" "auth0" {
  description        = "Auth0"
  path               = "oidc/auth0"
  type               = "oidc"
  oidc_discovery_url = local.secrets["vault"]["auth0"]["issuer_url"]
  oidc_client_id     = local.secrets["vault"]["auth0"]["client_id"]
  oidc_client_secret = local.secrets["vault"]["auth0"]["client_secret"]
  default_role       = "auth0"

  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "auth0" {
  backend   = vault_jwt_auth_backend.auth0.path
  role_name = "auth0"

  allowed_redirect_uris = [
    "https://vault.siliconsheep.se/ui/vault/auth/${vault_jwt_auth_backend.auth0.path}/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
  bound_audiences = [local.secrets["vault"]["auth0"]["client_id"]]
  token_policies  = ["default"]
  groups_claim    = "https://siliconsheep/groups"
  user_claim      = "sub"
}

resource "vault_jwt_auth_backend" "google" {
  description        = "Google"
  oidc_discovery_url = "https://accounts.google.com"
  path               = "oidc/google"
  type               = "oidc"
  default_role       = "gmail"
  oidc_client_id     = local.secrets["vault"]["google"]["client_id"]
  oidc_client_secret = local.secrets["vault"]["google"]["client_secret"]

  tune {
    listing_visibility = "hidden"
  }
}

resource "vault_jwt_auth_backend_role" "gmail" {
  backend   = vault_jwt_auth_backend.google.path
  role_name = "gmail"

  allowed_redirect_uris = ["https://vault.siliconsheep.se/ui/vault/auth/${vault_jwt_auth_backend.google.path}/oidc/callback"]
  bound_audiences       = [local.secrets["vault"]["google"]["client_id"]]
  bound_claims_type     = "string"
  bound_claims = {
    email = local.secrets["users"]["dieter"]["email"]
  }
  claim_mappings = {
    email = "email"
    name  = "name"
  }

  oidc_scopes    = ["openid", "email", "profile"]
  token_policies = ["admin"]
  role_type      = "oidc"
  token_ttl      = 3600
  user_claim     = "email"
}
