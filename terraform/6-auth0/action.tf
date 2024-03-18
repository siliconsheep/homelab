resource "auth0_action" "add_roles" {
  name    = "add-roles"
  runtime = "node16"
  code    = file("${path.module}/scripts/add-roles.js")
  deploy  = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }
}

resource "auth0_action" "link_social_accounts" {
  name    = "link-social-accounts"
  runtime = "node16"
  code    = file("${path.module}/scripts/link-social-accounts.js")
  deploy  = true

  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  dependencies {
    name    = "auth0"
    version = "3.5.0"
  }

  secrets {
    name  = "AUTH0_DOMAIN"
    value = module.auth0_actions_client.domain
  }

  secrets {
    name  = "AUTH0_CLIENT_ID"
    value = module.auth0_actions_client.client_id
  }

  secrets {
    name  = "AUTH0_CLIENT_SECRET"
    value = module.auth0_actions_client.client_secret
  }
}

resource "auth0_trigger_actions" "login_flow" {
  trigger = "post-login"

  actions {
    display_name = "link-social-accounts"
    id           = auth0_action.link_social_accounts.id
  }

  actions {
    display_name = "add-roles"
    id           = auth0_action.add_roles.id
  }
}
