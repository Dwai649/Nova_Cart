

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "RG-TFSTATE"
    storage_account_name = "sttfstatenovacart"
    container_name       = "tfstate"
    key                  = "bootstrap.terraform.tfstate" 
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    app_name     = "Novacart_Ecomm"
    app_location = "Sweden"
    CostCenter   = 514327
    Department   = "StoreOps"
    managed_by   = "bootstrap-stack"
  }
}

resource "azurerm_resource_group" "acr" {
  name     = var.acr_resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = var.acr_sku

  
  admin_enabled = false

  tags = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

# Lets the CI principal push images without admin credentials.
resource "azurerm_role_assignment" "ci_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = var.ci_principal_object_id
}
