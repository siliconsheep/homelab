terraform {
  required_providers {
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

provider "vault" {}

provider "kubernetes" {
  alias          = "siliconsheep-home"
  config_path    = var.kube_config_path
  config_context = "siliconsheep-home"
}

provider "kubernetes" {
  alias          = "siliconsheep-oke"
  config_path    = var.kube_config_path
  config_context = "siliconsheep-oke"
}
