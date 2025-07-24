subscription_id           = "2701d72f-0511-4d07-91d8-8e4c1d1476ad"
resource_group_name       = "rg-private"
location                  = "eastus"

vnet_name                 = "vnet-private"
vnet_address_space        = ["10.2.0.0/16"]
private_subnet_name       = "subnet-private"
private_subnet_prefix     = ["10.2.2.0/24"]
public_subnet_name        = "public-subnet"
public_subnet_prefix      = ["10.2.3.0/24"]

nsg_name                  = "nsg-vm"
ssh_rule_priority         = 1001
winrm_rule_priority       = 1003
allowed_ssh_source        = "*"
allowed_winrm_source      = "*"

admin_username            = "azureuser"
admin_password            = "ChangeThis123!"
ssh_public_key_path       = "~/.ssh/id_rsa.pub"

security_rules = [
  {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowWinRM"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

windows_pip_name = "windows-public-ip"

vms = [
  {
    name      = "ubuntu-vm"
    os        = "linux"
    vm_size   = "Standard_B1s"
    disk_type = "Standard_LRS"
    public    = false
    image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
  },
  {
    name      = "centos-vm"
    os        = "linux"
    vm_size   = "Standard_B1s"
    disk_type = "Standard_LRS"
    public    = false
    image = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "7_9-gen2"
      version   = "latest"
    }
  },
  {
    name      = "windows-vm"
    os        = "windows"
    vm_size   = "Standard_B1s"
    disk_type = "Standard_LRS"
    public    = true
    image = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
  }
]

ansible_vnet_name = "vnet-ansible"
ansible_vnet_rg   = "rg-ansible"
