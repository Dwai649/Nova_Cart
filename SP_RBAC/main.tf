terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "RG-TFSTATE"
    storage_account_name = "sttfstatenovacart"
    container_name       = "sp-tfstate"
    key                  = "identity.terraform.tfstate" # separate from both bootstrap and dev
  }
}

provider "azurerm" {
  features {}
}
provider "azuread" {}

data "azuread_client_config" "current" {}

data "azurerm_client_config" "sub" {}




resource "azuread_application" "github_ci" {
  
  display_name = "AAP-Terraform-Actions"
  
}

resource "azuread_service_principal" "sp_client" {
  client_id = azuread_application.github_ci.client_id
}

resource "azuread_service_principal_password" "sp_pass" {
  service_principal_id = azuread_service_principal.sp_client.id

  
  end_date = timeadd(timestamp(), "8760h") # ~1 year

  lifecycle {
  
    ignore_changes = [end_date]
  }
}

# Contributor on the dev resource group - lets the main stack's `terraform
# apply` create/manage VNet, NSGs, Postgres, Container Apps, and the
# AcrPull role assignment it grants the app-runtime identity.
resource "azurerm_role_assignment" "dev_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.sub.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp_client.object_id
}

# Contributor alone cannot create role assignments - the main stack's
# AcrPull grant for its own managed identity needs this too.
resource "azurerm_role_assignment" "dev_rbac_admin" {
  scope                = "/subscriptions/${data.azurerm_client_config.sub.subscription_id}"
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azuread_service_principal.sp_client.object_id
}

# Push access to the registry, scoped to its own resource group - separate
# from the dev RG entirely.
resource "azurerm_role_assignment" "acr_push" {
  scope                = "/subscriptions/${data.azurerm_client_config.sub.subscription_id}"
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.sp_client.object_id
}
