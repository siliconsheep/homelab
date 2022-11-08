terraform {
  backend "s3" {
    bucket   = "terraform-state"
    key      = "oci/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}