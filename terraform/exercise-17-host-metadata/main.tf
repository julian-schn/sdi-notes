# Exercise 17 - Host Metadata Generation
# Builds on Exercise 16 by adding auto-incrementing server names and metadata module

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

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  # Token is automatically read from HCLOUD_TOKEN environment variable
}

# Local provider (used for generating helper scripts/files)
provider "local" {}

# Null provider (used for local-exec helpers)
provider "null" {}

# Data source to query existing servers for auto-incrementing
data "hcloud_servers" "existing" {}

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
}

# Primary SSH Key Resource
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-primary-ssh-key"
  public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Secondary SSH Key Resource (optional)
resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key"
  public_key = var.ssh_public_key_secondary

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Data source to lookup existing firewalls with matching labels
data "hcloud_firewalls" "existing" {
  with_selector = "project=${var.project},managed_by=terraform"
}

# Local to determine if we should create a new firewall
locals {
  # Try to find existing firewall by name
  existing_firewall = try(
    one([for fw in data.hcloud_firewalls.existing.firewalls : fw if fw.name == "${var.project}-firewall"]),
    null
  )
  should_create_firewall = local.existing_firewall == null
}

# Create firewall only if it doesn't exist
resource "hcloud_firewall" "server_firewall" {
  count = local.should_create_firewall ? 1 : 0
  
  name = "${var.project}-firewall"

  # SSH access
  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTP access
  rule {
    direction = "in"
    port      = "80"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Allow all outbound traffic
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

# Local to reference either existing or newly created firewall
locals {
  firewall_id = local.should_create_firewall ? hcloud_firewall.server_firewall[0].id : local.existing_firewall.id
}

# Local values
locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
}

# Hetzner Cloud Server Resource
resource "hcloud_server" "main_server" {
  name        = local.server_name  # AUTO-INCREMENTED NAME
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Keys
  ssh_keys = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )

  # Firewall
  firewall_ids = [local.firewall_id]

  # Network configuration
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Labels
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    server_num  = tostring(local.next_server_number)
  }

  # Cloud-init configuration
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name     = local.server_name
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
  }
}

# Generate deployment-scoped known_hosts file
resource "null_resource" "known_hosts" {
  depends_on = [hcloud_server.main_server]

  triggers = {
    server_ip = hcloud_server.main_server.ipv4_address
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      mkdir -p "${path.module}/gen"
      
      # Wait for SSH to be ready and scan host keys
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

# SSH wrapper script
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

# SCP wrapper script
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

# NEW: Host Metadata Module
module "host_metadata" {
  source = "./modules/host_metadata"

  name     = local.server_name
  ipv4     = hcloud_server.main_server.ipv4_address
  ipv6     = hcloud_server.main_server.ipv6_address
  location = hcloud_server.main_server.location
}
