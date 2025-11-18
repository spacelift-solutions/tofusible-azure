terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "ssh_public_key" {
  type        = string
  description = "The public SSH key to use for VM authentication"
}

variable "private_key_path" {
  type        = string
  description = "The path to the private key to use for SSH"
}

variable "resource_group_name" {
  type        = string
  description = "The Azure resource group name where resources will be created"
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to use for the VM network interfaces"
}

variable "location" {
  type        = string
  description = "The Azure location/region where resources will be created"
  default     = "eastus"
}

provider "azurerm" {
  features {}
}

###############################
## Create Azure VMs
###############################

# Public IP for production VM
resource "azurerm_public_ip" "tofu_production" {
  name                = "tofu-production-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name        = "tofu production"
    Environment = "production"
  }
}

# Network interface for production VM
resource "azurerm_network_interface" "tofu_production" {
  name                = "tofu-production-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tofu_production.id
  }

  tags = {
    Name        = "tofu production"
    Environment = "production"
  }
}

# Production VM
resource "azurerm_linux_virtual_machine" "tofu_production" {
  name                = "tofu-production"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s" # Equivalent to t2.micro
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.tofu_production.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    Name        = "tofu production"
    Environment = "production"
  }
}

# Public IP for QA VM
resource "azurerm_public_ip" "tofu_qa" {
  name                = "tofu-qa-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name        = "tofu qa"
    Environment = "qa"
  }
}

# Network interface for QA VM
resource "azurerm_network_interface" "tofu_qa" {
  name                = "tofu-qa-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tofu_qa.id
  }

  tags = {
    Name        = "tofu qa"
    Environment = "qa"
  }
}

# QA VM
resource "azurerm_linux_virtual_machine" "tofu_qa" {
  name                = "tofu-qa"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s" # Equivalent to t2.micro
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.tofu_qa.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    Name        = "tofu qa"
    Environment = "qa"
  }
}

# Public IP for Dev VM
resource "azurerm_public_ip" "tofu_dev" {
  name                = "tofu-dev-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name        = "tofu dev"
    Environment = "dev"
  }
}

# Network interface for Dev VM
resource "azurerm_network_interface" "tofu_dev" {
  name                = "tofu-dev-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tofu_dev.id
  }

  tags = {
    Name        = "tofu dev"
    Environment = "dev"
  }
}

# Dev VM
resource "azurerm_linux_virtual_machine" "tofu_dev" {
  name                = "tofu-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s" # Equivalent to t2.micro
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.tofu_dev.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    Name        = "tofu dev"
    Environment = "dev"
  }
}

##############################################################
## Add Tofu production To The Inventory !IMPORTANT
##############################################################
module "host_tofu_production" {
  source  = "spacelift.io/spacelift-solutions/tofusible-host/spacelift"
  version = "1.0.0"

  host                 = azurerm_public_ip.tofu_production.ip_address
  user                 = "ubuntu"
  ssh_private_key_file = var.private_key_path
  groups               = ["tofu", "production", "example.production"]
}

##############################################################
## Add Tofu qa To The Inventory !IMPORTANT
##############################################################
module "host_tofu_qa" {
  source  = "spacelift.io/spacelift-solutions/tofusible-host/spacelift"
  version = "1.0.0"

  host                 = azurerm_public_ip.tofu_qa.ip_address
  user                 = "ubuntu"
  ssh_private_key_file = var.private_key_path
  groups               = ["tofu", "qa", "example.qa"]
}

##############################################################
## Add Tofu dev To The Inventory !IMPORTANT
##############################################################
module "host_tofu_dev" {
  source  = "spacelift.io/spacelift-solutions/tofusible-host/spacelift"
  version = "1.0.0"

  host                 = azurerm_public_ip.tofu_dev.ip_address
  user                 = "ubuntu"
  ssh_private_key_file = var.private_key_path
  groups               = ["tofu", "dev", "example.dev"]

}

############################################################################################
## Output the full inventory so we can pass it to ansible !IMPORTANT
## Note: we just output the spec in a list, do NOT json encode this. Just raw output
############################################################################################
output "inventory_tofu" {
  value = [
    module.host_tofu_production.spec,
    module.host_tofu_qa.spec,
    module.host_tofu_dev.spec
  ]

  # It does have to be sensitive, as the module could take passwords as an input.
  # If you want to use this on a private worker you *MUST* enable sensitive output uploading.
  # This example utilizes a public worker to create the output
  # and public workers do not require that setting.
  # See more: https://docs.spacelift.io/concepts/stack/stack-dependencies#enabling-sensitive-outputs-for-references
  sensitive = true
}