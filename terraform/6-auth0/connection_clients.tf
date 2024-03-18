resource "auth0_connection_client" "dhome_default_connection" {
  connection_id = auth0_connection.default.id
  client_id     = module.dhome.client_id
}

resource "auth0_connection_client" "dhome_google_connection" {
  connection_id = auth0_connection.google.id
  client_id     = module.dhome.client_id
}

resource "auth0_connection_client" "dhome_github_connection" {
  connection_id = auth0_connection.github.id
  client_id     = module.dhome.client_id
}

resource "auth0_connection_client" "dhome_oke_default_connection" {
  connection_id = auth0_connection.default.id
  client_id     = module.dhome_oke.client_id
}

resource "auth0_connection_client" "dhome_oke_google_connection" {
  connection_id = auth0_connection.google.id
  client_id     = module.dhome_oke.client_id
}

resource "auth0_connection_client" "dhome_oke_github_connection" {
  connection_id = auth0_connection.github.id
  client_id     = module.dhome_oke.client_id
}

