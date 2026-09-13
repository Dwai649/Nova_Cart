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
  tags = local.tags
}


module "network" {
    source = "../Modules/vnet_subnet"

    vnet_name = "VNET-${local.prefix}"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = var.vnet_address_space
   
}

resource "azurerm_subnet" "app" {
  name                 = "SNET-APP-${local.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name 
  virtual_network_name = module.network.vnet_name 
  address_prefixes     = var.container_app_subnet

  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
/*
resource "azurerm_subnet" "DB" {
  name                 = "SNET-DB-${local.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name 
  virtual_network_name = module.network.vnet_name
  address_prefixes     = var.db_subnet

  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
*/
module "app_nsg" {
  source = "../Modules/nsg"

  name                 = "NSG-APP-${local.prefix}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name

  subnet_id = azurerm_subnet.app.id
  security_rules = {
    allow_http = {
      priority                = 101
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "80"
      source_address_prefix   = "*"
      destination_address_prefix = "*"
    }
    allow_https = {
      priority                = 100
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "443"
      source_address_prefix   = "*"
      destination_address_prefix = "*"
    }

   
    allow_aca_lb_inbound = {
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "AzureLoadBalancer"
      destination_address_prefix  = "*"
    }

    allow_aca_intra_subnet = {
      priority                    = 111
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = azurerm_subnet.app.address_prefixes[0]
      destination_address_prefix  = "*"
    }
    allow_aca_outbound_azure_cloud = {
      priority                    = 120
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "*"
      destination_address_prefix  = "AzureCloud"
    }
    allow_aca_outbound_acr = {
      priority                    = 121
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "*"
      destination_address_prefix  = "MicrosoftContainerRegistry"
    }
    allow_aca_outbound_storage = {
      priority                    = 122
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "443"
      source_address_prefix       = "*"
      destination_address_prefix  = "Storage"
    }
  }
}

/* module "db_nsg" {
  source = "../Modules/nsg"

  name                 = "NSG-DB-${local.prefix}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name

  subnet_id = azurerm_subnet.DB.id
  security_rules = {
    allow_db_from_app_subnet = {
      priority                    = 100
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      destination_port_range      = "5432"
      source_address_prefix       = azurerm_subnet.app.address_prefixes[0] 
      destination_address_prefix  = "*"
    }
  }
}

*/


module "postgres_DB" {
  source = "../Modules/postgres_DB" 
  server_name =      var.server_name
  database_name = var.database_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  postgres_version = var.postgres_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

}






