# Autograder, Lab 4: the root configuration calls the module once per server.
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

run "two_servers_by_default" {
  command = plan

  assert {
    condition     = azurerm_resource_group.main.name == "rg-cao-lab4-student"
    error_message = "In the default workspace the resource group is rg-<prefix>-<owner> (keep the given code)."
  }

  assert {
    condition     = toset(keys(module.web)) == toset(["web1", "web2"])
    error_message = "module \"web\" must have one instance per entry of var.vms (for_each = var.vms): web1 and web2."
  }

  assert {
    condition     = module.web["web2"].public_ip == null
    error_message = "web2 asks for no public IP: pass each.value.public_ip to the module."
  }

  assert {
    condition     = data.azurerm_platform_image.ubuntu.offer == "ubuntu-24_04-lts" && data.azurerm_platform_image.ubuntu.sku == "server"
    error_message = "data.azurerm_platform_image.ubuntu must look up Canonical / ubuntu-24_04-lts / server."
  }
}

run "three_servers" {
  command = apply

  variables {
    vms = {
      web1 = {}
      web2 = { public_ip = false }
      api  = { size = "Standard_B1ms" }
    }
  }

  assert {
    condition     = length(module.web) == 3 && module.web["api"].name == "vm-cao-lab4-api"
    error_message = "Adding an entry to var.vms must add a server, named vm-<prefix>-<key>."
  }
}

run "big_vm_refused" {
  command = plan

  variables {
    vms = {
      web1 = { size = "Standard_D4s_v5" }
    }
  }

  expect_failures = [var.vms]
}
