variable "azure_integration_id" {
  type        = string
  description = "The Azure Integration to use for child stacks."
  default     = "01JAZPBRW3K2YB0K7F58NZSDY6" # Update this with your Azure integration ID
}

variable "resource_space_id" {
  type        = string
  description = "The Space ID to use for created resources."
  default     = "opentofu-01JB2XV5E3ZR3NDTKCN80KS6RH"
}

variable "ansible_worker_pool_id" {
  type        = string
  description = "The worker pool ID to use for ansible jobs."
  default     = "01JCZY4WD38EJS5S94B64E0V1Z"
}

variable "resource_group_name" {
  type        = string
  description = "The Azure resource group name where resources will be created."
  default     = "tofusible-rg" # Update this with your Azure resource group
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to launch VMs in within the OpenTofu stack."
  default     = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET/subnets/YOUR_SUBNET"
}

variable "azure_location" {
  type        = string
  description = "The Azure region/location where resources will be created."
  default     = "eastus"
}

variable "create_additional_dependency_for_demos" {
  type        = bool
  description = "Whether to create an additional dependency resource for demo purposes."
  default     = false
}

variable "azure_subscription_id" {
  type        = string
  description = "The Azure subscription ID where resources will be created."
}