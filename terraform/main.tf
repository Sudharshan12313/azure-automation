# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network and Subnet
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

# NSG
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = var.ssh_rule_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_source
    destination_address_prefix = "*"
  }
}

# NICs
resource "azurerm_network_interface" "ubuntu_nic" {
  name                = var.ubuntu_nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "centos_nic" {
  name                = var.centos_nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "windows_nic" {
  name                = var.windows_nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NSG associations
resource "azurerm_network_interface_security_group_association" "ubuntu_nsg" {
  network_interface_id      = azurerm_network_interface.ubuntu_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "centos_nsg" {
  network_interface_id      = azurerm_network_interface.centos_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "windows_nsg" {
  network_interface_id      = azurerm_network_interface.windows_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Ubuntu VM
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                = var.ubuntu_vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.ubuntu_vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.ubuntu_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  disable_password_authentication = true

  source_image_reference {
    publisher = var.ubuntu_image_publisher
    offer     = var.ubuntu_image_offer
    sku       = var.ubuntu_image_sku
    version   = var.ubuntu_image_version
  }

  os_disk {
    storage_account_type = var.ubuntu_disk_type
    caching              = "ReadWrite"
  }
}

# CentOS VM
resource "azurerm_linux_virtual_machine" "centos_vm" {
  name                = var.centos_vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.centos_vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.centos_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  disable_password_authentication = true

  source_image_reference {
    publisher = var.centos_image_publisher
    offer     = var.centos_image_offer
    sku       = var.centos_image_sku
    version   = var.centos_image_version
  }

  os_disk {
    storage_account_type = var.centos_disk_type
    caching              = "ReadWrite"
  }
}

# Windows VM
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = var.windows_vm_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.windows_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.windows_nic.id]

  source_image_reference {
    publisher = var.windows_image_publisher
    offer     = var.windows_image_offer
    sku       = var.windows_image_sku
    version   = var.windows_image_version
  }

  os_disk {
    storage_account_type = var.windows_disk_type
    caching              = "ReadWrite"
  }

  license_type = "Windows_Client"
}
