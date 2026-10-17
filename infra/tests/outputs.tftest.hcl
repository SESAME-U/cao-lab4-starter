# Autograder, Lab 4: the outputs, after a mocked apply.
# Editing this file does not change your grade: the instructor's copy is used.

mock_provider "azurerm" {
  # Mocked resources still go through the provider's checks, which expect
  # real Azure resource IDs: give each referenced resource a valid-looking one.
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
    }
  }
  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg"
    }
  }
  mock_resource "azurerm_public_ip" {
    defaults = {
      id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip"
      ip_address = "20.10.20.30"
    }
  }
  mock_resource "azurerm_network_interface" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/nic"
      private_ip_address = "10.40.1.4"
    }
  }
  mock_data "azurerm_platform_image" {
    defaults = {
      version = "24.04.202510010"
    }
  }
}

variables {
  owner               = "student"
  ssh_public_key_path = "./tests/fixtures/test_key.pub"
}

run "outputs" {
  command = apply

  assert {
    condition     = output.image_version == "24.04.202510010"
    error_message = "output image_version must be the version read by data.azurerm_platform_image.ubuntu."
  }

  assert {
    condition     = output.private_ips == { web1 = "10.40.1.4", web2 = "10.40.1.4" }
    error_message = "output private_ips must map every server name to its private IP."
  }

  assert {
    condition     = output.web_urls == { web1 = "http://20.10.20.30" }
    error_message = "output web_urls must map only the servers that have a public IP to http://<public IP>."
  }

  assert {
    condition     = output.ssh_commands == { web1 = "ssh -i ~/.ssh/cao_lab azureuser@20.10.20.30" }
    error_message = "output ssh_commands must map only the servers that have a public IP to their ssh command."
  }
}
