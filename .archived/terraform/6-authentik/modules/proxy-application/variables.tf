variable "name" {
  description = "Name of the application"
  type        = string
}

variable "external_host" {
  description = "Hostname of the application"
  type        = string
}

variable "group" {
  description = "Group to assign the application to"
  type        = string
}

variable "icon_url" {
  description = "URL to the application's icon"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the application"
  type        = string
}

variable "open_in_new_tab" {
  description = "Open the application in a new tab"
  type        = bool
  default     = true
}
