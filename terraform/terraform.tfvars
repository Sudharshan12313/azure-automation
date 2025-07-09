subscription_id           = "2701d72f-0511-4d07-91d8-8e4c1d1476ad"
resource_group_name       = "rg-private"
location                  = "eastus"

vnet_name                 = "vnet-private"
vnet_address_space        = ["10.0.0.0/16"]
private_subnet_name       = "subnet-private"
private_subnet_prefix     = ["10.0.2.0/24"]

nsg_name                  = "nsg-vm"
ssh_rule_priority         = 1001
allowed_ssh_source        = "*"  # Replace with secure IP in production

admin_username            = "azureuser"
admin_password            = "ChangeThis123!"  # Used for Windows VM
ssh_public_key_path       = "~/.ssh/id_rsa.pub"

ubuntu_vm_name            = "ubuntu-vm"
ubuntu_nic_name           = "nic-ubuntu"
ubuntu_vm_size            = "Standard_B1s"
ubuntu_disk_type          = "Standard_LRS"
ubuntu_image_publisher    = "Canonical"
ubuntu_image_offer        = "0001-com-ubuntu-server-focal"
ubuntu_image_sku          = "20_04-lts-gen2"
ubuntu_image_version      = "latest"

centos_vm_name            = "centos-vm"
centos_nic_name           = "nic-centos"
centos_vm_size            = "Standard_B1s"
centos_disk_type          = "Standard_LRS"
centos_image_publisher    = "OpenLogic"
centos_image_offer        = "CentOS"
centos_image_sku          = "7_9-gen2"
centos_image_version      = "latest"

windows_vm_name           = "windows-vm"
windows_nic_name          = "nic-windows"
windows_vm_size           = "Standard_B1s"
windows_disk_type         = "Standard_LRS"
windows_image_publisher   = "MicrosoftWindowsServer"
windows_image_offer       = "WindowsServer"
windows_image_sku         = "2019-Datacenter"
windows_image_version     = "latest"
