variable "prefix" {
  description = "Short name used in every resource name."
  type        = string
  default     = "cao-lab4"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "owner" {
  description = "Your GitHub username, used in tags and in the resource group name."
  type        = string
}

variable "admin_username" {
  description = "Administrator account on every VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key."
  type        = string
  default     = "~/.ssh/cao_lab.pub"
}

# One entry per server. The key (web1, web2) is the server's short name;
# omitted attributes take the default given by optional().
variable "vms" {
  description = "Servers to create, by short name."
  type = map(object({
    size      = optional(string, "Standard_B1s")
    public_ip = optional(bool, true)
  }))
  default = {
    web1 = {}
    web2 = { public_ip = false }
  }

  # TODO Lab 4, Part C: a validation block that refuses the whole map when
  # any server asks for a size other than Standard_B1s, Standard_B1ms or
  # Standard_B2s. Hint: alltrue() and a for expression over values(var.vms).
}
