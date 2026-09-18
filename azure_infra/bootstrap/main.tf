
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

  resource "azurerm_resource_group" "RG_ACR" {
    name     = var.acr_resource_group_name
    location = var.location
    tags     = local.tags
  }

  resource "azurerm_container_registry" "acr" {
    name                = var.acr_name
    resource_group_name = azurerm_resource_group.RG_ACR.name
    location            = azurerm_resource_group.acr.location
    sku                 = var.acr_sku

  
    admin_enabled = false

    tags = local.tags

    lifecycle {
     
      prevent_destroy = true
    }
  }

resource "azuread_application" "github_ci" {
  display_name = "github-ci-sp"
}

resource "azuread_service_principal" "acr_sp" {
  client_id = azuread_application.github_ci.client_id
}

resource "azuread_service_principal_password" "acr_sp_pass" {
  service_principal_id = azuread_service_principal.acr_sp.id 
}

resource "azurerm_role_assignment" "acr_role" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id = azuread_service_principal.acr_sp.object_id

  
}

