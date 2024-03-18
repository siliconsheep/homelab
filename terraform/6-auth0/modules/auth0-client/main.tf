resource "auth0_client" "this" {
  name        = var.name
  description = var.description
  app_type    = var.app_type
  logo_uri    = var.logo_uri

  initiate_login_uri  = var.initiate_login_uri
  allowed_logout_urls = var.allowed_logout_urls
  allowed_origins     = var.allowed_origins
  callbacks           = var.callbacks

  grant_types     = var.grant_types
  oidc_conformant = var.oidc_conformant

  jwt_configuration {
    alg = "RS256"
  }

  native_social_login {
    apple {
      enabled = false
    }

    facebook {
      enabled = false
    }
  }
}

resource "auth0_client_grant" "this" {
  for_each = var.api_grants

  client_id = auth0_client.this.id
  audience  = each.key
  scope     = each.value
}

resource "auth0_client_credentials" "this" {
  client_id = auth0_client.this.id

  authentication_method = "client_secret_post"
}
