# Exercise 17 - Host Metadata Generation
# Builds on Exercise 16 by adding auto-incrementing server names and metadata module

data "hcloud_ssh_keys" "all" {}

terraform {
  required_version = ">= 1.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.46"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "hcloud" {}

provider "local" {}

provider "null" {}

# Data source to query existing servers for auto-incrementing
data "hcloud_servers" "existing" {}

data "hcloud_ssh_key" "existing_primary" {
  count = var.existing_ssh_key_name != "" ? 1 : 0
  name  = var.existing_ssh_key_name
}

data "hcloud_ssh_key" "existing_secondary" {
  count = var.existing_ssh_key_secondary_name != "" ? 1 : 0
  name  = var.existing_ssh_key_secondary_name
}

# Local to calculate next server number
locals {
  # Extract numbers from existing servers matching our naming pattern
  existing_server_numbers = [
    for server in data.hcloud_servers.existing.servers :
    tonumber(regex("^${var.server_base_name}-(\\d+)$", server.name)[0])
    if can(regex("^${var.server_base_name}-(\\d+)$", server.name))
  ]

  # Calculate next number (max + 1, or 1 if none exist)
  next_server_number = length(local.existing_server_numbers) > 0 ? max(local.existing_server_numbers...) + 1 : 1

  # Generate server name with auto-increment
  server_name = "${var.server_base_name}-${local.next_server_number}"

  existing_key_with_pubkey = try([
    for key in data.hcloud_ssh_keys.all.ssh_keys :
    key if key.public_key == var.ssh_public_key
  ][0], null)

  should_create_primary_key = var.existing_ssh_key_name == "" && local.existing_key_with_pubkey == null

  primary_ssh_key_id = var.existing_ssh_key_name != "" ? data.hcloud_ssh_key.existing_primary[0].id : (
    local.existing_key_with_pubkey != null ? local.existing_key_with_pubkey.id : hcloud_ssh_key.primary[0].id
  )

  secondary_ssh_key_id = var.ssh_public_key_secondary != "" ? (
    var.existing_ssh_key_secondary_name != "" ? data.hcloud_ssh_key.existing_secondary[0].id : hcloud_ssh_key.secondary[0].id
  ) : null

  ssh_key_ids = compact(concat(
    [local.primary_ssh_key_id],
    local.secondary_ssh_key_id != null ? [local.secondary_ssh_key_id] : []
  ))
}

resource "hcloud_ssh_key" "primary" {
  count      = local.should_create_primary_key ? 1 : 0
  name       = "${var.project}-primary-ssh-key"
  public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" && var.existing_ssh_key_secondary_name == "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key"
  public_key = var.ssh_public_key_secondary

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

resource "hcloud_firewall" "server_firewall" {
  name = "${var.project}-host-metadata-firewall"

  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    port      = "80"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "1-65535"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol  = "udp"
    port      = "1-65535"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Additional local values
locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
}

resource "hcloud_server" "main_server" {
  name        = local.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  ssh_keys = local.ssh_key_ids

  firewall_ids = [hcloud_firewall.server_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    server_num  = tostring(local.next_server_number)
  }

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name     = local.server_name
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "known_hosts" {
  depends_on = [hcloud_server.main_server]

  triggers = {
    server_ip = hcloud_server.main_server.ipv4_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      mkdir -p "${path.module}/gen"
      
      echo "Waiting for SSH to be ready on ${hcloud_server.main_server.ipv4_address}..."
      for i in {1..30}; do
        if ssh-keyscan -t ed25519 -T 5 ${hcloud_server.main_server.ipv4_address} 2>/dev/null | grep -q "ssh-ed25519"; then
          echo "SSH is ready, capturing host keys..."
          ssh-keyscan -t ed25519 ${hcloud_server.main_server.ipv4_address} > "${path.module}/gen/known_hosts" 2>/dev/null
          echo "Host keys saved to gen/known_hosts"
          exit 0
        fi
        echo "Attempt $i/30: SSH not ready yet, waiting 5 seconds..."
        sleep 5
      done
      
      echo "ERROR: SSH did not become available after 150 seconds"
      exit 1
    EOT
  }
}

resource "local_file" "ssh_wrapper" {
  depends_on = [hcloud_server.main_server]

  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    ip             = hcloud_server.main_server.ipv4_address
  })

  filename             = "${path.module}/bin/ssh"
  file_permission      = "0755"
  directory_permission = "0755"
}

resource "local_file" "scp_wrapper" {
  depends_on = [hcloud_server.main_server]

  content = templatefile("${path.module}/tpl/scp.sh", {
    devopsUsername = var.devops_username
    ip             = hcloud_server.main_server.ipv4_address
  })

  filename             = "${path.module}/bin/scp"
  file_permission      = "0755"
  directory_permission = "0755"
}

module "host_metadata" {
  source = "./modules/host_metadata"

  name     = local.server_name
  ipv4     = hcloud_server.main_server.ipv4_address
  ipv6     = hcloud_server.main_server.ipv6_address
  location = hcloud_server.main_server.location
}
