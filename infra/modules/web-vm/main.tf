# Lab 4, Part B: one web server, as a reusable module.
#
# Move the three server resources of Lab 3 here and make them generic:
# every name, size and setting comes from a variable (see variables.tf).
# The tests look for these addresses inside the module:
#
#   azurerm_public_ip.this                 count: one when var.public_ip is true, none otherwise
#   azurerm_network_interface.this         public_ip_address_id only when there is a public IP
#   azurerm_linux_virtual_machine.this     Ubuntu 24.04, SSH key only, cloud-init as custom_data
#
# Names: "pip-${var.name}", "nic-${var.name}", "vm-${var.name}".
