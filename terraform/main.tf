resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  address_prefixes     = var.private_subnet_prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  address_prefixes     = var.public_subnet_prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Loop over all VM definitions
resource "azurerm_network_interface" "nic" {
  for_each            = { for vm in var.vms : vm.name => vm }
  name                = "${each.value.name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = each.value.public ? azurerm_subnet.public.id : azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public ? azurerm_public_ip.pip[each.value.name].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each = azurerm_network_interface.nic
  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "pip" {
  for_each            = { for vm in var.vms : vm.name => vm if vm.public }
  name                = "${each.value.name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each = { for vm in var.vms : vm.name => vm if vm.os == "linux" }

  name                = each.value.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = each.value.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.disk_type
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each = { for vm in var.vms : vm.name => vm if vm.os == "windows" }

  name                = each.value.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = each.value.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.disk_type
  }

  license_type = "Windows_Client"
}

resource "azurerm_virtual_machine_extension" "winrm" {
  for_each = { for vm in var.vms : vm.name => vm if vm.os == "windows" }

  name                 = "enable-winrm-${each.key}"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = [
      "https://raw.githubusercontent.com/ansible/ansible/stable-2.9/examples/scripts/ConfigureRemotingForAnsible.ps1"
    ],
    commandToExecute = "powershell -ExecutionPolicy Bypass -File ConfigureRemotingForAnsible.ps1 -SkipNetworkProfileCheck -Verbose"
  })
}
