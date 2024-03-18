resource "auth0_email" "oci" {
  name    = "smtp"
  enabled = true

  default_from_address = local.secrets.smtp["from"]

  credentials {
    smtp_host = local.secrets.smtp["host"]
    smtp_port = 587
    smtp_user = local.secrets.smtp["user"]
    smtp_pass = local.secrets.smtp["pass"]
  }
}
