# Azure Authentication
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Networking
variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "private_subnet_prefix" {
  description = "CIDR prefix for the private subnet"
  type        = list(string)
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}

variable "public_subnet_prefix" {
  description = "CIDR prefix for the public subnet"
  type        = list(string)
}

# NSG Rules
variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "ssh_rule_priority" {
  description = "Priority for SSH rule"
  type        = number
}

variable "winrm_rule_priority" {
  description = "Priority for WinRM rule"
  type        = number
}

variable "allowed_ssh_source" {
  description = "CIDR to allow SSH from"
  type        = string
}

variable "allowed_winrm_source" {
  description = "CIDR to allow WinRM from"
  type        = string
}

variable "security_rules" {
  description = "List of custom NSG rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

# Admin Access
variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
}

variable "admin_password" {
  description = "Admin password for Windows VMs"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
}

# VM List
variable "vms" {
  description = "List of VMs to deploy"
  type = list(object({
    name       = string
    os         = string           # "linux" or "windows"
    vm_size    = string
    disk_type  = string
    public     = bool             # Whether VM needs public IP
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
}
