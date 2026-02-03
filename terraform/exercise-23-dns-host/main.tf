# Exercise 23 - Creating a Host with Corresponding DNS Entries
# Extends Exercise 16 by adding DNS records and using hostname in generated files

# Get all existing SSH keys to check if our public key already exists
data "hcloud_ssh_keys" "all" {}

# Data sources to lookup existing SSH keys (if reusing)
data "hcloud_ssh_key" "existing_primary" {
  count = var.existing_ssh_key_name != "" ? 1 : 0
  name  = var.existing_ssh_key_name
}

data "hcloud_ssh_key" "existing_secondary" {
  count = var.existing_ssh_key_secondary_name != "" ? 1 : 0
  name  = var.existing_ssh_key_secondary_name
}

# Local values
locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )

  # Full DNS hostname for the server
  server_fqdn = "${var.server_name}.${var.dns_zone}"
  dns_zone_with_dot = "${var.dns_zone}."

  # Find existing SSH key with matching public key
  existing_key_with_pubkey = try([
    for key in data.hcloud_ssh_keys.all.ssh_keys :
    key if key.public_key == var.ssh_public_key
  ][0], null)

  # Determine if we should create a new SSH key or use existing
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

# Primary SSH Key Resource
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

# Secondary SSH Key Resource (optional)
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

# Firewall for this exercise
resource "hcloud_firewall" "server_firewall" {
  name = "${var.project}-dns-host-firewall"

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

# Hetzner Cloud Server Resource
resource "hcloud_server" "main_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  # SSH Keys
  ssh_keys = local.ssh_key_ids

  # Firewall
  firewall_ids = [hcloud_firewall.server_firewall.id]

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
  }

  # Cloud-init configuration
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name     = var.server_name
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })

  # Lifecycle management
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================================
# DNS RECORDS - NEW in Exercise 23
# ============================================================================

# DNS A record for the server (workhorse.gxy.sdi.hdm-stuttgart.cloud)
resource "dns_a_record_set" "workhorse" {
  zone      = local.dns_zone_with_dot
  name      = var.server_name
  addresses = [hcloud_server.main_server.ipv4_address]
  ttl       = 10
}

# ============================================================================
# SSH KNOWN_HOSTS AND WRAPPER SCRIPTS - Using DNS hostname instead of IP
# ============================================================================

# Generate deployment-scoped known_hosts file using DNS hostname
resource "null_resource" "known_hosts" {
  depends_on = [
    hcloud_server.main_server,
    dns_a_record_set.workhorse
  ]

  triggers = {
    server_ip   = hcloud_server.main_server.ipv4_address
    server_fqdn = local.server_fqdn
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      mkdir -p "${path.module}/gen"
      
      # Wait for DNS to propagate and SSH to be ready
      echo "Waiting for DNS and SSH to be ready on ${local.server_fqdn}..."
      for i in {1..30}; do
        if ssh-keyscan -t ed25519 -T 5 ${local.server_fqdn} 2>/dev/null | grep -q "ssh-ed25519"; then
          echo "SSH is ready, capturing host keys for ${local.server_fqdn}..."
          ssh-keyscan -t ed25519 -T 5 ${local.server_fqdn} > "${path.module}/gen/known_hosts" 2>/dev/null
          echo "Host keys saved to gen/known_hosts"
          exit 0
        fi
        echo "Attempt $i/30: SSH/DNS not ready yet, waiting 5 seconds..."
        sleep 5
      done
      
      echo "ERROR: SSH did not become available after 150 seconds"
      exit 1
    EOT
  }
}

# SSH wrapper script - uses DNS hostname
resource "local_file" "ssh_wrapper" {
  depends_on = [
    hcloud_server.main_server,
    dns_a_record_set.workhorse
  ]

  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    hostname       = local.server_fqdn
  })

  filename             = "${path.module}/bin/ssh"
  file_permission      = "0755"
  directory_permission = "0755"
}

# SCP wrapper script - uses DNS hostname
resource "local_file" "scp_wrapper" {
  depends_on = [
    hcloud_server.main_server,
    dns_a_record_set.workhorse
  ]

  content = templatefile("${path.module}/tpl/scp.sh", {
    devopsUsername = var.devops_username
    hostname       = local.server_fqdn
  })

  filename             = "${path.module}/bin/scp"
  file_permission      = "0755"
  directory_permission = "0755"
}
