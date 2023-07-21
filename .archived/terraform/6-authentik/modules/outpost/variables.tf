variable "name" {
  type        = string
  description = "Name of the Kubernetes Outpost"
}

variable "local_connection" {
  type        = bool
  description = "If true, use the in-cluster config. If false, use the kubeconfig file."
  default     = false
}

variable "secret_name" {
  description = "Name of the Kubernetes secret containing the token / ca.crt"
  type        = string
  default     = null
}

variable "secret_namespace" {
  description = "The namespace of the Kubernetes secret containing the token / ca.crt"
  type        = string
  default     = null
}

variable "kube_config_path" {
  type        = string
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Context to use from kubeconfig file"
  default     = null
}

variable "protocol_providers" {
  type        = list(string)
  description = "List of protocol providers to associate with the outpost"
}
