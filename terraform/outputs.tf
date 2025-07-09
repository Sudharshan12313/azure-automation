# Output all Linux VM IPs as a list
output "linux_vm_ips" {
  description = "Private IPs of Linux VMs"
  value = [
    azurerm_network_interface.ubuntu_nic.private_ip_address,
    azurerm_network_interface.centos_nic.private_ip_address
  ]
}

# Output all Windows VM IPs as a list
output "windows_vm_ips" {
  description = "Private IPs of Windows VMs"
  value = [
    azurerm_network_interface.windows_nic.private_ip_address
  ]
}
