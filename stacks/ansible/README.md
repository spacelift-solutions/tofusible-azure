# Ansible Stack

This stack configures the virtual machines created in the OpenTofu stack.

**Note:** This stack is cloud-agnostic and works with any cloud provider. It receives VM information (IP addresses, SSH keys, etc.) from the OpenTofu stack via Spacelift stack dependencies and doesn't care whether those VMs are in Azure, AWS, GCP, or elsewhere.

## Files

- **`tofusible.yml`** - Contains the dynamic inventory plugin configuration
- **`inventory_plugins/`** - Directory containing the `tofusible.py` dynamic inventory plugin
- **`playbook.yml`** - The Ansible playbook that will be run on the virtual machines