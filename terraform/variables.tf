# Azure Auth
variable "subscription_id" {}
variable "location" {}
variable "resource_group_name" {}

# Networking
variable "vnet_name" {}
variable "vnet_address_space" {
  type = list(string)
}
variable "private_subnet_name" {}
variable "private_subnet_prefix" {
  type = list(string)
}

# NSG
variable "nsg_name" {}
variable "ssh_rule_priority" {}
variable "allowed_ssh_source" {}

# Common VM credentials
variable "admin_username" {}
variable "admin_password" {}
variable "ssh_public_key_path" {}

# Ubuntu VM
variable "ubuntu_vm_name" {}
variable "ubuntu_nic_name" {}
variable "ubuntu_vm_size" {}
variable "ubuntu_disk_type" {}
variable "ubuntu_image_publisher" {}
variable "ubuntu_image_offer" {}
variable "ubuntu_image_sku" {}
variable "ubuntu_image_version" {}

# CentOS VM
variable "centos_vm_name" {}
variable "centos_nic_name" {}
variable "centos_vm_size" {}
variable "centos_disk_type" {}
variable "centos_image_publisher" {}
variable "centos_image_offer" {}
variable "centos_image_sku" {}
variable "centos_image_version" {}

# Windows VM
variable "windows_vm_name" {}
variable "windows_nic_name" {}
variable "windows_vm_size" {}
variable "windows_disk_type" {}
variable "windows_image_publisher" {}
variable "windows_image_offer" {}
variable "windows_image_sku" {}
variable "windows_image_version" {}
