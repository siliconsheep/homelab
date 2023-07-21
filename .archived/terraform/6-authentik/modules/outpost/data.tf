# Run the commands below to get a kubeconfig file for authentik:

# # your server name goes here
# KUBE_API=https://localhost:8443

# SECRET_NAME=$(kubectl get serviceaccount {{ include "authentik-remote-cluster.fullname" . }} -o jsonpath='{.secrets[0].name}')
# KUBE_CA=$(kubectl get secret/$SECRET_NAME -o jsonpath='{.data.ca\.crt}')
# KUBE_TOKEN=$(kubectl get secret/$SECRET_NAME -o jsonpath='{.data.token}' | base64 --decode)

# echo "apiVersion: v1
# kind: Config
# clusters:
# - name: default-cluster
#   cluster:
#     certificate-authority-data: ${KUBE_CA}
#     server: ${KUBE_API}
# contexts:
# - name: default-context
#   context:
#     cluster: default-cluster
#     namespace: {{ .Release.Namespace }}
#     user: authentik-user
# current-context: default-context
# users:
# - name: authentik-user
#   user:
#     token: ${KUBE_TOKEN}"

data "kubernetes_secret_v1" "this" {
  count = var.local_connection ? 0 : 1
  metadata {
    name      = var.secret_name
    namespace = var.secret_namespace
  }

  # binary_data = {
  #   "ca.crt"  = ""
  #   token     = ""
  #   namespace = ""
  # }
}
