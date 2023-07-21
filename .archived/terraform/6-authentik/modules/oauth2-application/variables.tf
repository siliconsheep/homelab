variable "name" {
  description = "Name of the application"
  type        = string
}

variable "redirect_uris" {
  description = "Redirect URIs for the application"
  type        = list(string)
}

variable "group" {
  description = "Group to assign the application to"
  type        = string
}

variable "icon_url" {
  description = "URL to the application's icon"
  type        = string
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
