resource "auth0_role" "admins" {
  name        = "admins"
  description = "Site admins"
}

resource "auth0_role" "argocd_admin" {
  name        = "argocd-admins"
  description = "ArgoCD admins"
}

resource "auth0_role" "grafana_viewers" {
  name        = "grafana-viewers"
  description = "Grafana viewers"
}

resource "auth0_role" "grafana_editors" {
  name        = "grafana-editors"
  description = "Grafana editors"
}

resource "auth0_role" "grafana_admins" {
  name        = "grafana-admins"
  description = "Grafana admins"
}

resource "auth0_role" "k8s_admins" {
  name        = "k8s-admins"
  description = "Kubernetes cluster admins"
}

resource "auth0_role" "vault_admins" {
  name        = "vault-admins"
  description = "Vault admins"
}
