locals {
  private_key_full_path = "/mnt/workspace/${spacelift_mounted_file.ssh_private_key.relative_path}"
  public_key_full_path  = "/mnt/workspace/${spacelift_mounted_file.ssh_public_key.relative_path}"
}

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

resource "spacelift_mounted_file" "ssh_public_key" {
  context_id = spacelift_context.ssh_keys.id

  content = base64encode(tls_private_key.this.public_key_pem)
  relative_path = "spacelift.pub"
}

resource "spacelift_environment_variable" "ssh_public_key_path" {
  context_id = spacelift_context.ssh_keys.id

  name  = "TF_VAR_public_key_path"
  value = local.public_key_full_path
}