# Autograder, Lab 4: the web-vm module, tested on its own.
# Runs without Azure: the azurerm provider is mocked, nothing is created.
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
  name                = "test-web"
  location            = "westeurope"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  ssh_public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl test"
  cloud_init          = "#cloud-config\n"
  tags                = { course = "cao", owner = "student" }
}

run "server_with_public_ip" {
  command = apply

  module {
    source = "./modules/web-vm"
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 1
    error_message = "With public_ip = true (the default) the module must create exactly one azurerm_public_ip.this (use count)."
  }

  assert {
    condition     = azurerm_public_ip.this[0].allocation_method == "Static" && azurerm_public_ip.this[0].sku == "Standard"
    error_message = "The public IP must be Static with the Standard SKU."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.name == "vm-test-web" && azurerm_network_interface.this.name == "nic-test-web"
    error_message = "Names must come from var.name: vm-<name>, nic-<name>, pip-<name>."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.size == "Standard_B1s" && azurerm_linux_virtual_machine.this.admin_username == "azureuser"
    error_message = "The VM must use var.size and var.admin_username (defaults Standard_B1s and azureuser)."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.disable_password_authentication && contains([for k in azurerm_linux_virtual_machine.this.admin_ssh_key : k.public_key], var.ssh_public_key)
    error_message = "SSH key only: disable_password_authentication = true and admin_ssh_key with var.ssh_public_key."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.source_image_reference[0].offer == "ubuntu-24_04-lts"
    error_message = "The VM must run Ubuntu 24.04 (publisher Canonical, offer ubuntu-24_04-lts, sku server)."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.custom_data == base64encode(var.cloud_init)
    error_message = "custom_data must be var.cloud_init, base64-encoded by the module."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.tags["owner"] == "student" && azurerm_network_interface.this.tags["owner"] == "student"
    error_message = "Every resource of the module must carry var.tags."
  }

  assert {
    condition     = output.name == "vm-test-web" && output.private_ip == "10.40.1.4" && output.public_ip == "20.10.20.30"
    error_message = "The module outputs name, private_ip and public_ip must return the VM name and its two IP addresses."
  }
}

run "server_without_public_ip" {
  command = apply

  module {
    source = "./modules/web-vm"
  }

  variables {
    public_ip = false
    size      = "Standard_B2s"
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 0
    error_message = "With public_ip = false the module must create no public IP (count = 0)."
  }

  assert {
    condition     = azurerm_network_interface.this.ip_configuration[0].public_ip_address_id == null
    error_message = "Without a public IP, the network interface must set public_ip_address_id to null."
  }

  assert {
    condition     = output.public_ip == null
    error_message = "Without a public IP, output public_ip must be null."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this.size == "Standard_B2s"
    error_message = "The VM size must come from var.size."
  }
}

run "big_vm_refused" {
  command = plan

  module {
    source = "./modules/web-vm"
  }

  variables {
    size = "Standard_D4s_v5"
  }

  expect_failures = [var.size]
}
