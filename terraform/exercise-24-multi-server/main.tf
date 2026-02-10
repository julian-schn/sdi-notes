# Exercise 24 - Creating a Fixed Number of Servers
# Creates server_count servers with DNS entries and individual SSH wrappers

data "hcloud_ssh_keys" "all" {}

data "hcloud_ssh_key" "existing_primary" {
  count = var.existing_ssh_key_name != "" ? 1 : 0
  name  = var.existing_ssh_key_name
}

data "hcloud_ssh_key" "existing_secondary" {
  count = var.existing_ssh_key_secondary_name != "" ? 1 : 0
  name  = var.existing_ssh_key_secondary_name
}

locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )

  dns_zone_with_dot = "${var.dns_zone}."

  # Generate server names: work-1, work-2, etc.
  server_names = [for i in range(var.server_count) : "${var.server_base_name}-${i + 1}"]

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
  name = "${var.project}-multi-server-firewall"

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

# --- SERVERS - Create server_count instances ---

resource "hcloud_server" "servers" {
  count       = var.server_count
  name        = local.server_names[count.index]
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
    environment  = var.environment
    project      = var.project
    managed_by   = "terraform"
    server_index = tostring(count.index + 1)
  }

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name     = local.server_names[count.index]
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })

  lifecycle {
    create_before_destroy = true
  }
}

# --- DNS RECORDS - One A record per server ---

resource "dns_a_record_set" "servers" {
  count     = var.server_count
  zone      = local.dns_zone_with_dot
  name      = local.server_names[count.index]
  addresses = [hcloud_server.servers[count.index].ipv4_address]
  ttl       = 10
}

# --- SSH KNOWN HOSTS AND WRAPPER SCRIPTS - One per server ---

# Create server-specific directories
resource "null_resource" "create_dirs" {
  count = var.server_count

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "mkdir -p '${path.module}/${local.server_names[count.index]}/bin' '${path.module}/${local.server_names[count.index]}/gen'"
  }
}

# Generate known_hosts file for each server
resource "null_resource" "known_hosts" {
  count = var.server_count

  depends_on = [
    hcloud_server.servers,
    dns_a_record_set.servers,
    null_resource.create_dirs
  ]

  triggers = {
    server_ip   = hcloud_server.servers[count.index].ipv4_address
    server_fqdn = "${local.server_names[count.index]}.${var.dns_zone}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      SERVER_NAME="${local.server_names[count.index]}"
      SERVER_FQDN="${local.server_names[count.index]}.${var.dns_zone}"
      
      # Wait for DNS to propagate and SSH to be ready
      echo "Waiting for DNS and SSH to be ready on $SERVER_FQDN..."
      for i in {1..30}; do
        if ssh-keyscan -t ed25519 -T 5 $SERVER_FQDN 2>/dev/null | grep -q "ssh-ed25519"; then
          echo "SSH is ready, capturing host keys for $SERVER_FQDN..."
          ssh-keyscan -t ed25519 $SERVER_FQDN > "${path.module}/$SERVER_NAME/gen/known_hosts" 2>/dev/null
          echo "Host keys saved to $SERVER_NAME/gen/known_hosts"
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

# SSH wrapper script for each server
resource "local_file" "ssh_wrapper" {
  count = var.server_count

  depends_on = [null_resource.create_dirs]

  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    hostname       = "${local.server_names[count.index]}.${var.dns_zone}"
  })

  filename             = "${path.module}/${local.server_names[count.index]}/bin/ssh"
  file_permission      = "0755"
  directory_permission = "0755"
}

# SCP wrapper script for each server
resource "local_file" "scp_wrapper" {
  count = var.server_count

  depends_on = [null_resource.create_dirs]

  content = templatefile("${path.module}/tpl/scp.sh", {
    devopsUsername = var.devops_username
    hostname       = "${local.server_names[count.index]}.${var.dns_zone}"
  })

  filename             = "${path.module}/${local.server_names[count.index]}/bin/scp"
  file_permission      = "0755"
  directory_permission = "0755"
}
