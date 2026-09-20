variable "location" {
    default = "West US"
    type = string
  
}

variable "vnet_address_space" {
    default = [ "10.0.0.0/16" ]
    type = list(string)
  
}

variable "server_name" {
  default = "novacartdbserver01"
  type = string
}

variable "database_name" {
  default = "novacart"
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


variable "container_app_subnet" {
  default = [ "10.0.1.0/24" ]
  type = list(string)
  
}

variable "db_subnet" {
  default = [ "10.0.2.0/24" ]
  type = list(string)
  
}

variable "dns_zone_name" {
  default = "privatelink.postgres.database.azure.com"
  type = string 
}

variable "link_name" {
  default = "postgres-vnet-link"
  type = string
  
}

variable "acr_name" {
   type = string

}

variable "acr_resource_group_name" {
  type = string
  
}

variable "backend_image_tag" {
  type = string
  
}

variable "administrator_login" {
  default =  "db01_novacart_admin"
  type = string
  
}