terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.10"
    }
  }

  # Remote state in Azure Storage (Part A). The values that change per student
  # (resource group, storage account, container, key) live in backend.hcl,
  # written by "make bootstrap" and ignored by Git. Authentication uses your
  # az login and Entra ID: no storage account key anywhere.
  backend "azurerm" {
    use_azuread_auth = true
    use_cli          = true
  }
}
