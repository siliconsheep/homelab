locals {
  secrets = yamldecode(file("/secrets.yaml"))
}
