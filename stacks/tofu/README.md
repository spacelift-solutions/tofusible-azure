# The OpenTofu Stack (Azure)

This stack creates Azure virtual machines in OpenTofu and then generates an output that the Ansible stack can use to configure the virtual machines.

## How It Works

1. We create the virtual machines in OpenTofu using Azure resources:
   - `azurerm_public_ip` - Static public IP addresses for external access
   - `azurerm_network_interface` - Network interfaces connecting VMs to your subnet
   - `azurerm_linux_virtual_machine` - Ubuntu 24.04 LTS virtual machines
2. We use the `tofusible_host` module to gather information about the virtual machines we created.
3. We output the `tofusible_host`s as a list of hosts in OpenTofu (using native OpenTofu outputs).

## Azure Resources Created

This stack creates three environments (production, qa, dev), each with:
- 1x Static Public IP (`azurerm_public_ip`)
- 1x Network Interface (`azurerm_network_interface`)
- 1x Linux Virtual Machine (`azurerm_linux_virtual_machine`) - Standard_B1s with Ubuntu 24.04 LTS

## Prerequisites

You'll need:
- An existing Azure Resource Group
- An existing Azure Virtual Network with a subnet
- The subnet should allow SSH access (port 22) for Ansible to connect

Check out the readme in `modules/tofusible_host` to learn more about the module and how to configure it.

Take a look at the OpenTofu code for more details.