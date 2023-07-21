resource "random_password" "client_id" {
  length  = 40
  special = false
}

resource "random_password" "client_secret" {
  length  = 128
  special = false
}

resource "authentik_provider_oauth2" "this" {
  name               = var.name
  client_id          = random_password.client_id.result
  client_secret      = random_password.client_secret.result
  redirect_uris      = var.redirect_uris
  signing_key        = data.authentik_certificate_key_pair.this.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings  = data.authentik_scope_mapping.this.ids
}

resource "authentik_application" "this" {
  name              = var.name
  slug              = lower(replace(replace(var.name, " ", "-"), "/[()]/", ""))
  group             = var.group
  protocol_provider = authentik_provider_oauth2.this.id
  meta_icon         = var.icon_url
  meta_description  = var.description
  open_in_new_tab   = var.open_in_new_tab
}
