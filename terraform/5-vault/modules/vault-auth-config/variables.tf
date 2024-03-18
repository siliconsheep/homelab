variable "kube_config_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Context to use from kubeconfig file"
}

variable "secret_name" {
  type        = string
  description = "Name of secret (associated with Vault service account) to extract token from"
}

variable "secret_namespace" {
  type        = string
  description = "Namespace of secret (associated with Vault service account) to extract token from"
  default     = "vault"
}

variable "vault_mount_path" {
  type        = string
  description = "Mount path of Kubernetes auth method"
  default     = ""
}
