# The subscription comes from the environment: make plan and make apply set
# ARM_SUBSCRIPTION_ID from "az account show". Nothing secret is written here.
provider "azurerm" {
  features {}

  # Since azurerm 5.0 the provider registers no Azure resource providers by
  # default. Register only the two this lab needs.
  resource_providers_to_register = [
    "Microsoft.Compute",
    "Microsoft.Network",
  ]
}
