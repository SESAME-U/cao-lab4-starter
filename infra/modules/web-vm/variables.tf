# The module's inputs: its interface. Given complete; do not rename them,
# the tests call the module with these names.

variable "name" {
  description = "Short name of this server, used in every resource name (for example cao-lab4-web1)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the server goes into."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet the network interface joins."
  type        = string
}

variable "size" {
  description = "VM size. B-series only: student credit."
  type        = string
  default     = "Standard_B1s"

  validation {
    condition     = contains(["Standard_B1s", "Standard_B1ms", "Standard_B2s"], var.size)
    error_message = "Use Standard_B1s, Standard_B1ms or Standard_B2s."
  }
}

variable "admin_username" {
  description = "Administrator account on the VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Content of the SSH public key (not a path)."
  type        = string
}

variable "cloud_init" {
  description = "cloud-init configuration, as plain text. The module encodes it."
  type        = string
}

variable "public_ip" {
  description = "Give this server a public IP address."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for every resource of the module."
  type        = map(string)
  default     = {}
}
