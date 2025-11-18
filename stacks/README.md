# The Stacks (Azure Implementation)

Browse each stack to see what it does and how it works.

- `admin` - The Spacelift admin stack that sets up the OpenTofu and Ansible stacks (with Azure integration) as well as creates the stack dependency between them.
- `tofu` - The OpenTofu stack that creates the Azure virtual machines.
- `ansible` - The Ansible stack that configures the virtual machines (cloud-agnostic).
    - This directory also has an `inventory_plugins` directory that contains the `tofusible.py` dynamic inventory plugin.