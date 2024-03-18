resource "scaleway_iam_application" "velero" {
  name = "Velero"
}

resource "scaleway_iam_policy" "velero_object_read_write" {
  name           = "velero-rw"
  description    = "Gives access to Velero to write to backup bucket"
  application_id = scaleway_iam_application.velero.id
  rule {
    project_ids          = [data.scaleway_account_project.homelab.id]
    permission_set_names = ["ObjectStorageFullAccess"]
  }
}

resource "scaleway_iam_api_key" "velero_credentials" {
  application_id     = scaleway_iam_application.velero.id
  description        = "Velero credentials for writing to backup bucket"
  default_project_id = data.scaleway_account_project.homelab.id
}

resource "vault_kv_secret_v2" "velero_credentials_secret" {
  mount               = "/secret"
  name                = "/infra/scaleway"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      s3-credentials        = <<EOT
[default]
aws_access_key_id = "${scaleway_iam_api_key.velero_credentials.access_key}"
aws_secret_access_key = "${scaleway_iam_api_key.velero_credentials.secret_key}"
EOT
      aws-access-key-id     = scaleway_iam_api_key.velero_credentials.access_key
      aws-secret-access-key = scaleway_iam_api_key.velero_credentials.secret_key
      aws-endpoints         = "https://s3.fr-par.scw.cloud"
      aws-region            = "fr-par"
    }
  )
}
