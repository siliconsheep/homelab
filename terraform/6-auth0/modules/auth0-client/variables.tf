variable "name" {
  description = "Name of the application"
  type        = string
}

variable "description" {
  description = "Description of the application"
  type        = string
  default     = null
}

variable "app_type" {
  description = "Type of the application"
  type        = string
  default     = null
}

variable "logo_uri" {
  description = "URL to the application's logo"
  type        = string
  default     = null
}

variable "initiate_login_uri" {
  description = "URL to the application's login page"
  type        = string
  default     = null
}

variable "allowed_origins" {
  description = "Allowed origins for the application"
  type        = list(string)
  default     = null
}

variable "allowed_logout_urls" {
  description = "Allowed logout URLs for the application"
  type        = list(string)
  default     = null
}

variable "callbacks" {
  description = "Allowed callbacks for the application"
  type        = list(string)
  default     = null
}

variable "grant_types" {
  description = "Allowed grant types for the application"
  type        = list(string)
  default     = null
}

variable "oidc_conformant" {
  description = "Whether the application is OIDC conformant"
  type        = bool
  default     = null
}

variable "api_grants" {
  description = "API grants for the application"
  type        = map(list(string))
  default     = {}
}
