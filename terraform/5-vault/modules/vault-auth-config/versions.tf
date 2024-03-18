terraform {
  required_version = ">=0.13.0"

  required_providers {
    kubernetes = ">= 2.15, < 3.0"
    vault      = ">= 3.11.0, < 4.0"
  }
}
