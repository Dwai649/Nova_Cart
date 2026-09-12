variable "location" {
    default = "West US"
    type = string
  
}

variable "vnet_address_space" {
    type = list(string)
  
}

variable "subnets" {
    type = map(object({
      address_prefixes = list(string) 
    }))

  
}