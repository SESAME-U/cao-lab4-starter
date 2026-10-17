# A module declares the providers it uses. The version is chosen by the
# root configuration that calls it (infra/versions.tf).
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
