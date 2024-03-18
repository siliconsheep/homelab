resource "oci_identity_group" "mail-senders" {
  compartment_id = var.tenancy
  description    = "Users allowed to send mail"
  name           = "mail-senders"
  defined_tags   = merge(local.defined_tags, { "Siliconsheep.Service" = "SMTP" })
}

resource "oci_identity_user" "smtp_user" {
  compartment_id = var.tenancy
  description    = "SMTP user"
  name           = "smtp"
  email          = "noreply@siliconsheep.se"
  defined_tags   = merge(local.defined_tags, { "Siliconsheep.Service" = "SMTP" })
}

resource "oci_identity_user_group_membership" "mail_senders_users" {
  group_id = oci_identity_group.mail-senders.id
  user_id  = oci_identity_user.smtp_user.id
}

resource "oci_identity_policy" "mail_senders_policy" {
  compartment_id = var.tenancy
  description    = "Policy to allow mail-senders to send mail"
  name           = "mail-senders"
  statements = [
    "Allow group ${oci_identity_group.mail-senders.name} to use email-family in tenancy",
    "Allow group ${oci_identity_group.mail-senders.name} to manage credentials in tenancy where target.credential.type = 'smtp'",
    "Allow group ${oci_identity_group.mail-senders.name} to manage email-family in tenancy",
    "Allow group ${oci_identity_group.mail-senders.name} to manage suppressions in tenancy",
    "Allow group ${oci_identity_group.mail-senders.name} to manage log-groups in tenancy",
    "Allow group ${oci_identity_group.mail-senders.name} to read log-content in tenancy",
  ]
  defined_tags = merge(local.defined_tags, { "Siliconsheep.Service" = "SMTP" })
}

# TODO: Create this in Terraform and store the credentials somewhere
# resource "oci_identity_smtp_credential" "test_smtp_credential" {
#   description = "SMTP credentials for outbound email"
#   user_id     = oci_identity_user.smtp_user.id
# }

resource "oci_email_email_domain" "siliconsheep-se" {
  compartment_id = var.tenancy
  name           = "siliconsheep.se"
  defined_tags   = merge(local.defined_tags, { "Siliconsheep.Service" = "SMTP" })
}

resource "oci_email_dkim" "siliconsheep-se-dkim" {
  email_domain_id = oci_email_email_domain.siliconsheep-se.id
  defined_tags    = merge(local.defined_tags, { "Siliconsheep.Service" = "SMTP" })
  description     = "DKIM for siliconsheep.se"
  name            = "oracle-se-202212"
}

resource "oci_email_sender" "noreply-siliconsheep-se" {
  compartment_id = var.tenancy
  email_address  = "noreply@siliconsheep.se"
  defined_tags   = merge(local.defined_tags, { "Siliconsheep.Service" = "SMTP" })
}

resource "cloudflare_record" "dkim" {
  zone_id = data.cloudflare_zone.siliconsheep-se.id
  name    = "${oci_email_dkim.siliconsheep-se-dkim.name}._domainkey"
  value   = oci_email_dkim.siliconsheep-se-dkim.cname_record_value
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "spf" {
  zone_id = data.cloudflare_zone.siliconsheep-se.id
  name    = "siliconsheep.se"
  value   = oci_email_sender.noreply-siliconsheep-se.is_spf
  type    = "TXT"
}
