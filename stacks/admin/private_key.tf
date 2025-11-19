resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "spacelift_context" "ssh_keys" {
  name = "tofusible-azure-ssh-key"

  space_id = var.resource_space_id

  labels = ["tofusible", "azure"]
}

resource "spacelift_mounted_file" "ssh_private_key" {
  context_id    = spacelift_context.ssh_keys.id
  content       = base64encode(tls_private_key.this.private_key_pem)
  relative_path = "spacelift.pem"
}

resource "spacelift_environment_variable" "ssh_private_key_path" {
  context_id = spacelift_context.ssh_keys.id

  name  = "TF_VAR_private_key_path"
  value = local.private_key_full_path
}

locals {
  private_key_full_path = "/mnt/workspace/${spacelift_mounted_file.ssh_private_key.relative_path}"
}