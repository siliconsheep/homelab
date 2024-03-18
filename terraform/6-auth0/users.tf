resource "auth0_user" "dieter" {
  connection_name = auth0_connection.default.name

  name     = local.secrets["users"]["dieter"]["email"]
  nickname = "dieter"
  email    = local.secrets["users"]["dieter"]["email"]
  password = local.secrets["users"]["dieter"]["password"]

  blocked        = false
  email_verified = true
  picture        = "https://s.gravatar.com/avatar/0e840c4607e58c510774bcf301b5b534?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fdb.png"

  user_metadata = jsonencode(
    {
      additional_emails = local.secrets["users"]["dieter"]["additional_emails"]
    }
  )

  # Until we remove the ability to operate changes on
  # the roles field it is important to have this
  # block in the config, to avoid diffing issues.
  lifecycle {
    ignore_changes = [roles]
  }
}

resource "auth0_user_roles" "dieter_roles" {
  user_id = auth0_user.dieter.id
  roles = [
    auth0_role.admins.id,
    auth0_role.argocd_admin.id,
    auth0_role.k8s_admins.id,
    auth0_role.grafana_admins.id,
    auth0_role.vault_admins.id
  ]
}
