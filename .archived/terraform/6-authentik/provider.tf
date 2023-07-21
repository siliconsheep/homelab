terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2022.10.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.11.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.15"
    }
  }
}

provider "authentik" {}

provider "vault" {}

provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = "siliconsheep-home"
}
