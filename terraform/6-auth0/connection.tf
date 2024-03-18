resource "auth0_connection" "default" {
  name     = "Default"
  strategy = "auth0"

  options {
    disable_signup         = true
    brute_force_protection = true
  }
}

resource "auth0_connection" "google" {
  name     = "Google"
  strategy = "google-oauth2"

  options {
    client_id                = local.secrets["google"]["client_id"]
    client_secret            = local.secrets["google"]["client_secret"]
    scopes                   = ["email", "profile"]
    set_user_root_attributes = "on_each_login"
  }
}

resource "auth0_connection" "github" {
  name     = "GitHub"
  strategy = "github"

  options {
    client_id                = local.secrets["github"]["client_id"]
    client_secret            = local.secrets["github"]["client_secret"]
    scopes                   = ["email", "profile"]
    set_user_root_attributes = "on_each_login"
  }
}
