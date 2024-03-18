resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Siliconsheep internal CA"

  default_lease_ttl_seconds = 2630000 # 1 month
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_config_urls" "pki-urls" {
  backend = vault_mount.pki.path
  issuing_certificates = [
    "https://vault.siliconsheep.se/v1/${vault_mount.pki.path}/ca",
  ]
  crl_distribution_points = [
    "https://vault.siliconsheep.se/v1/${vault_mount.pki.path}/crl",
  ]
}

resource "vault_pki_secret_backend_root_cert" "pki-root-cert" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "Siliconsheep Internal CA"
  ttl                  = "315360000" # 10 years
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "Vault"
  organization         = "Siliconsheep"

  depends_on = [
    vault_mount.pki
  ]
}

resource "vault_pki_secret_backend_role" "authentik" {
  backend            = vault_mount.pki.path
  name               = "authentik"
  ttl                = 2630000 # 1 month
  allow_ip_sans      = false
  key_type           = "rsa"
  key_bits           = 4096
  allowed_domains    = ["auth.siliconsheep.se"]
  allow_subdomains   = false
  allow_bare_domains = true
}
