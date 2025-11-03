# Primary SSH Key Resource
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-primary-ssh-key"
  public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    key_type    = "primary"
  }
}

# Secondary SSH Key Resource
resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key"
  public_key = var.ssh_public_key_secondary

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    key_type    = "secondary"
  }
}

# Firewall Resource
resource "hcloud_firewall" "server_firewall" {
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

  # Allow all outbound traffic
  rule {
    direction = "out"
    protocol  = "icmp"
    destination_ips = [
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

# Data source to get existing servers for auto-increment
data "hcloud_servers" "existing" {}

# Local value for auto-incrementing server name
locals {
  existing_server_numbers = [
    for server in data.hcloud_servers.existing.servers :
    tonumber(regex("^${var.server_base_name}-(\\d+)$", server.name)[0])
    if can(regex("^${var.server_base_name}-(\\d+)$", server.name))
  ]
  next_server_number = length(local.existing_server_numbers) > 0 ? max(local.existing_server_numbers...) + 1 : 1
  server_name        = "${var.server_base_name}-${local.next_server_number}"
}

# Hetzner Cloud Server Resource
resource "hcloud_server" "main_server" {
  name        = local.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Keys primary + secondary if provided
  ssh_keys = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )

  # Firewall
  firewall_ids = [hcloud_firewall.server_firewall.id]

  # Network configuration
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Security: Disable deprecated images
  allow_deprecated_images = false

  # Enable backups for production environments
  backups = var.environment == "production" ? true : false

  # Labels for better resource management
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    server_type = var.server_type
  }

  # User data for initial server setup
  user_data = <<-EOF
    #!/bin/bash
    # Update system packages
    apt-get update && apt-get upgrade -y
    
    # Install essential packages
    apt-get install -y curl wget git htop vim ufw
    
    # Configure firewall
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw --force enable
    
    # Log completion
    echo "$(date): Server initialization completed" >> /var/log/user-data.log
  EOF

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}
