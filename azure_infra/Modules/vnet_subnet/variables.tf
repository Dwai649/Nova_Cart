variable "vnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  description = "Map of subnets"

  type = map(object({
    address_prefixes = list(string)

    delegation = optional(object({
      name = string
      actions = list(string)
    }))
  }))
}