resource "authentik_provider_proxy" "this" {
  name               = var.name
  external_host      = var.external_host
  mode               = "forward_single"
  token_validity     = "hours=1"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "this" {
  name              = var.name
  slug              = lower(replace(replace(var.name, " ", "-"), "/[()]/", ""))
  group             = var.group
  protocol_provider = resource.authentik_provider_proxy.this.id
  meta_icon         = var.icon_url
  meta_description  = var.description
  open_in_new_tab   = var.open_in_new_tab
}
