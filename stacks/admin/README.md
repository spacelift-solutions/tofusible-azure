# The Admin Stack (Azure)

This admin stack creates the OpenTofu and Ansible stacks with Azure integration as well as creates the stack dependency between them.
This is not _super_ necessary but it makes explaining all the parts of the process easier because you can see how the ansible and the opentofu stacks are configured.

This implementation uses Azure-specific resources and integrations. The child stacks are configured to create and manage Azure VMs.

Feel free to look at the OpenTofu files in this stack to see how the child stacks should be configured.

## Spin this thing up

You can create an admin stack and point it to this directory and it will setup the whole `tofusible` show so you can see how it works.

### Admin stack considerations

You need to configure this admin stack to match your environment and your Azure subscription.

When setting up the admin stack, the following environment variables should be added to it:

- `TF_VAR_azure_location` - The Azure region/location you want to deploy to (e.g., "eastus")
- `TF_VAR_azure_integration_id` - The Azure Integration to use for child stacks.
- `TF_VAR_resource_space_id` - The Space ID to use for created resources.
- `TF_VAR_ansible_worker_pool_id` - The worker pool ID to use for ansible jobs.
- `TF_VAR_resource_group_name` - The Azure resource group name where resources will be created.
- `TF_VAR_subnet_id` - The full Azure subnet ID to launch VMs in (format: `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}`).

The stack should also be an [administrative stack](https://docs.spacelift.io/concepts/stack/stack-settings#administrative) and have an Azure integration attached to it.
You can see an example of this stack being stood up in our demo environment [here](https://github.com/spacelift-solutions/demo/blob/main/admin/stacks_opentofu_spacelift.tf#L1) (just note we're using the default variables in the demo environment, so you'd still need to add those).