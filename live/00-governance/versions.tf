terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-plant-lz-state"
    storage_account_name = "stplantlz8e922cf2"
    container_name       = "tfstate"
    key                  = "governance.tfstate"
    use_azuread_auth     = true
  }
}
