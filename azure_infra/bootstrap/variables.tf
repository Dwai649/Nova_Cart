variable "location" {
  type    = string
  default = "westus"
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

variable "ci_principal_object_id" {
  description = "Object ID (not app ID) of the CI service principal that pushes images. az ad sp show --id <app-id> --query id -o tsv"
  type        = string
}
