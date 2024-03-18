output "client_id" {
  value = auth0_client.this.id
}

output "client_secret" {
  value = auth0_client_credentials.this.client_secret
}

output "domain" {
  value = data.auth0_tenant.this.domain
}
