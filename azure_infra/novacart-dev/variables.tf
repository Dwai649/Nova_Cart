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

variable "server_name" {
  default = "novacartdbserver01"
  type = string
}

variable "database_name" {
  default = "novacart"
  type = string
}


variable "administrator_login" {
  type = string
}

variable "administrator_password" {
  type      = string
  sensitive = true
}

variable "postgres_version" {
  type    = string
  default = "16"

}

variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
 
}

variable "storage_mb" {
  type    = number
  default = 32768

}