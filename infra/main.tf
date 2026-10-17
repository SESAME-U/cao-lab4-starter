# Lab 4: the Lab 3 infrastructure, refactored.
#
# Given: the shared part (resource group, network, firewall), as in Lab 3.
# Yours: the data source and the module call (Part C, at the end of the file).

locals {
  # Workspace suffix: empty in the default workspace, "-stage" in "stage".
  suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"

  tags = {
    course    = "cao"
    lab       = "4"
    owner     = var.owner
    workspace = terraform.workspace
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-${var.owner}${local.suffix}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}${local.suffix}"
  address_space       = ["10.40.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.40.1.0/24"]
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-${var.prefix}-web${local.suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# Lab 4, Part C: write below this line.
#
# TODO data "azurerm_platform_image" "ubuntu"
#      Reads which Ubuntu 24.04 build "latest" means today in var.location:
#      publisher Canonical, offer ubuntu-24_04-lts, sku server.
#
# TODO module "web"
#      source ./modules/web-vm, one instance per entry of var.vms (for_each).
#      name: "${var.prefix}-${each.key}${local.suffix}"; size and public_ip
#      from each.value; the subnet above; your SSH public key (file +
#      pathexpand); cloud-init.yaml read with file(); local.tags.
