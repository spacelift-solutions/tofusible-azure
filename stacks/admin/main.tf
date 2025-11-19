terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "spacelift" {}

locals {
  required_dependencies = {
    TOFUSIBLE = {
      child_stack_id = module.stack_ansible.id
      references = {
        # NOTE: This output is *sensitive* as it could hold passwords
        # If you want to use this on a private worker you *MUST* enable sensitive output uploading.
        # This example utilizes a public worker to create the output (see the stack_tofu above)
        # and public workers do not require that setting.
        # See more: https://docs.spacelift.io/concepts/stack/stack-dependencies#enabling-sensitive-outputs-for-references
        INVENTORY = {
          trigger_always = true
          # This is the name of the output in the OpenTofu stack that holds the host information
          output_name = "inventory_tofu"
          # This input name is reference in the `tofusible.yml` file
          # It tells the dynamic inventory where to get information about the hosts
          # Created in OpenTofu
          input_name = "TOFUSIBLE_INVENTORY"
        }
      }
    }
  }

  optional_dependencies = var.create_additional_dependency_for_demos ? {
    TOFUSIBLE_ADDITONAL = {
      child_stack_id = module.stack_additional[0].id
      references = {
        INVENTORY = {
          trigger_always = true
          output_name    = "inventory_tofu"
          input_name     = "TF_VAR_tofusible_inventory"
        }
      }
    }
  } : {}

  none_empty_optional_dependencies = {
    for k, v in local.optional_dependencies : k => v if length(v) > 0
  }

  dependencies = merge(
    local.required_dependencies,
    local.none_empty_optional_dependencies
  )
}

module "stack_opentofu" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Stack that creates Azure VMs"
  name            = "Tofusible - Azure - OpenTofu"
  repository_name = "tofusible"
  space_id        = var.resource_space_id

  auto_deploy = true

  azure_integration = {
    enabled         = true
    id              = var.azure_integration_id
    subscription_id = var.azure_subscription_id
  }

  environment_variables = {
    # This is the Azure resource group where resources will be created
    TF_VAR_resource_group_name = {
      value     = var.resource_group_name
      sensitive = false
    }

    # This is the subnet where the VMs will be created
    TF_VAR_subnet_id = {
      value     = var.subnet_id
      sensitive = false
    }

    # Azure region/location for resources
    TF_VAR_location = {
      value     = var.azure_location
      sensitive = false
    }
  }

  dependencies = local.dependencies

  contexts = {
    tofusible_ssh_key = spacelift_context.ssh_keys.id
  }

  labels            = ["tofusible", "azure", "opentofu", "infracost"]
  project_root      = "stacks/tofu"
  repository_branch = "main"
}

module "stack_ansible" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  description     = "Stack that configures Azure VMs"
  name            = "Tofusible - Azure - Ansible"
  repository_name = "tofusible"
  space_id        = var.resource_space_id

  auto_deploy = true

  environment_variables = {
    # !IMPORTANT
    # This variable tells ansible where to find the inventory file
    ANSIBLE_INVENTORY = {
      value     = "tofusible.yml"
      sensitive = false
    }
  }

  contexts = {
    # We attach the ssh key to the stack so ansible can use it to connect to the servers
    tofusible_ssh_key = spacelift_context.ssh_keys.id
  }

  labels            = ["tofusible", "azure", "ansible"]
  project_root      = "stacks/ansible"
  repository_branch = "main"

  workflow_tool    = "ANSIBLE"
  ansible_playbook = "playbook.yml"

  hooks = {
    before = {
      # !IMPORTANT
      # WE *must* chmod the tofusible.yml and private key files for ansible to use them.
      init  = ["chmod 644 tofusible.yml", "chmod 600 ${local.private_key_full_path}", "mkdir -p /tmp/.ansible && chmod 777 /tmp/.ansible"]
      apply = ["chmod 644 tofusible.yml", "chmod 600 ${local.private_key_full_path}", "mkdir -p /tmp/.ansible && chmod 777 /tmp/.ansible"]
    }
  }

  worker_pool_id = var.ansible_worker_pool_id
}

module "stack_additional" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  count = var.create_additional_dependency_for_demos ? 1 : 0

  description     = "Stack that creates null resources"
  name            = "Tofusible - Azure - Additional"
  repository_name = "tofusible"
  space_id        = var.resource_space_id

  auto_deploy = true

  labels            = ["tofusible", "azure", "additional", "infracost"]
  project_root      = "stacks/tofu/additional"
  repository_branch = "main"
}