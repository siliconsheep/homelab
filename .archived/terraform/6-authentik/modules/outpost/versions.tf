terraform {
  required_version = ">=0.13.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "~> 2022.10.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.15"
    }
  }
}
