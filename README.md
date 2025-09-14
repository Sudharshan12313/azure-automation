# azure-automation

# azure-automation

Go to your Terraform Cloud workspace > Variables and add:

Key: ssh_public_key

Value: (Paste content of id_rsa.pub)

Category: Terraform Variable

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

Comment or remove the TFvars value for ssh public key path

admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }


84054aa0-85bd-4a3e-a51d-67825e9e135f
