variable "location" {
  type    = string
  default = "west US"
}

variable "acr_name" {
  description = "Globally unique registry name (alphanumeric only)"
  type        = string
  default     = "novacartecommapp"
}

variable "acr_resource_group_name" {
  description = "Resource group for the registry - deliberately separate from the dev environment's RG"
  type        = string
  default     = "RG-RET-02"
}

variable "acr_sku" {
  type    = string
  default = "Standard"
}


