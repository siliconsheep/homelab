terraform {
  required_version = ">=0.13.0"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.50.0"
    }
  }
}
