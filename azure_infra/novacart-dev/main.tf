locals {
  project = "NOVACART"
  environment = "DEV"

  prefix = "${local.project}-${local.environment}"
  tags = {"app_name" = "Novacart_Ecomm",
  "app_location" = "Sweden",
  "CostCenter" = 514327
  "Department" = "StoreOps"
}
}

resource "azurerm_resource_group" "rg" {
  name = "RG-${local.prefix}"
  location = var.location
  tags = locals.tags
}


module "network" {
    source = "../Modules/vnet_subnet"

    vnet_name = "VNET-${local.prefix}"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = var.vnet_address_space
    subnets = var.subnets
   
    

}

module "app_nsg" {
    source = "../Modules/nsg" 

    name  =  "NSG-APP-${local.prefix}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name

    subnet_id = module.network.subnet_ids["app"]
    security_rules = {
      allow_http = {
        priority = 101
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"

        source_address_prefix = "*"
        destination_address_prefix = "*"

      }
      allow_https = {
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "443"

        source_address_prefix = "*"
        destination_address_prefix = "*"

      }

}
}

module "db_nsg" {
 
    source = "../Modules/nsg" 

    name  =  "NSG-DB-${local.prefix}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name

    subnet_id = module.network.subnet_ids["db"]
     security_rules = {
      allow_DBaccess = {
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "5432"

        source_address_prefix = "*"
        destination_address_prefix = "*"

      }

}
}

