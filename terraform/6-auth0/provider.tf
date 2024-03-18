terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.50.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.11.0"
    }
  }
}

provider "auth0" {}

provider "vault" {}
