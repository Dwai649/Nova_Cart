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
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

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
    
  }
}

 module "db_nsg" {
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

module "postgres_dns" {
  source = "../Modules/private_dns"

  dns_zone_name      = var.dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name

  virtual_network_id = module.network.vnet_id

  link_name = "postgres-vnet-link"
}






module "postgres_DB" {
  source = "../Modules/postgres_DB" 
  server_name =      var.server_name
  database_name = var.database_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  private_dns_zone_id = module.postgres_dns.private_dns_zone_id # from the ouputs described in the module DNS Zones 
  postgres_version = var.postgres_version
  delegated_subnet_id = azurerm_subnet.DB.id
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

}


data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

# ---------------------------------------------------------------------------
# Managed identity for ACR image pulls
#
# Replaces the admin username/password approach: no registry credential
# exists as a Terraform secret or a container secret anywhere. The identity
# is granted AcrPull on the registry and both apps authenticate as it.
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "aca_pull" {
  name                = "ID-ACAPULL-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_pull.principal_id
}










module "aca_env" {
  source = "../Modules/container_environment"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  aca_environment_name = "ACA-${local.prefix}"
  log_analytics_name = "LOG-${local.prefix}"
  subnet_id = azurerm_subnet.app.id

   depends_on = [module.app_nsg]

}

resource "azurerm_container_app" "backend" {
  name                         = "backend-novacart"
  container_app_environment_id = module.aca_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type = "UserAssigned" 
    identity_ids = [azurerm_user_assigned_identity.aca_pull.id]
  }

  secret {
    name  = "postgres-password"
    value = var.administrator_password
  }
  secret {
    name = "database-url"
    value = "postgresql://${var.administrator_login}:${var.administrator_password}@${module.postgres_DB.server_fqdn}:5432/${var.database_name}?sslmode=require"
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_pull.id
  }


  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "backend"
      image  = "${data.azurerm_container_registry.acr.login_server}/my-backend:${var.backend_image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "POSTGRES_USER"
        value = var.administrator_login
      }
      env {
        name  = "POSTGRES_DB"
        value = var.database_name
      }
      env {
        name  = "APP_ENV"
        value = "development"
      }
      env {
        name  = "API_VERSION"
        value = "v1"
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgres-password"
      }
      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }
    }
  }

  ingress {
    external_enabled = false 
    target_port      = 8080
    transport         = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = local.tags

  depends_on = [module.postgres_DB,azurerm_role_assignment.acr_pull]
}
/*
resource "azurerm_container_app" "frontend" {
  name                         = "frontend-novacart"
  container_app_environment_id = module.aca_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  secret {
    name  = "acr-password"
    value = data.azurerm_container_registry.acr.admin_password
  }

  registry {
    server               = data.azurerm_container_registry.acr.login_server
    username             = data.azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "frontend"
      image  = "${data.azurerm_container_registry.acr.login_server}/frontendimg:v1.0.0_pr-82eb2e12bbd6efd352ace81569641fac37622b11"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
     
        name  = "BACKEND_HOST"
        value = azurerm_container_app.backend.ingress[0].fqdn
      }
      env {
     
        name  = "BACKEND_PORT"
        value = "443"
      }
      env {
        name  = "APP_ENV"
        value = "development"
      }
    }
  }

  ingress {
    external_enabled = true 
    target_port      = 8081
    transport         = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = local.tags

  depends_on = [azurerm_container_app.backend]
}

*/ 








