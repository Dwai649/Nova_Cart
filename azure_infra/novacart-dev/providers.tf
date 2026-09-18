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
    container_name       = "terraformstate-novacartdev"
    key                  = "dev.terraform.tfstate" # Name of the state file blob
  }
}




# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

