

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
    container_name       = "bootstrap-tf"
    key                  = "bootstrap.terraform.tfstate" # NOT dev.terraform.tfstate
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

resource "azurerm_resource_group" "RG2" {
  name     = var.acr_resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.RG2.name
  location            = azurerm_resource_group.RG2.location
  sku                 = var.acr_sku

  # Pulls use the managed identity created in the main stack; pushes use the
  # CI principal's own Entra ID token via `az acr login`. Neither needs the
  # admin account, so it stays off.
  admin_enabled = false

  tags = local.tags

  lifecycle {
    # Images are the whole point of this registry - never let a plan quietly
    # replace it. Remove this only when you genuinely intend to lose them.
    prevent_destroy = true
  }
}

