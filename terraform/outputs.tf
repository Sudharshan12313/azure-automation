# Output all Linux VM private IPs
output "linux_vm_ips" {
  description = "Private IPs of all Linux VMs"
  value = [
    for vm in var.vms : azurerm_network_interface.nic[vm.name].private_ip_address
    if vm.os == "linux"
  ]
}

# Output all Windows VM private IPs
output "windows_vm_ips" {
  description = "Private IPs of all Windows VMs"
  value = [
    for vm in var.vms : azurerm_network_interface.nic[vm.name].private_ip_address
    if vm.os == "windows"
  ]
}

# Optional: Output all public IPs (for VMs that requested public IP)
output "vm_public_ips" {
  description = "Public IPs of VMs with public access"
  value = {
    for vm in var.vms : vm.name => try(azurerm_public_ip.pip[vm.name].ip_address, null)
    if vm.public
  }
}
