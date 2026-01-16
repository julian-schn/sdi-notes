# Exercise 26 - Testing Your Web Certificate
# Creates a server with Nginx SSL and multiple DNS entries

locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
  
  dns_zone_with_dot = "${var.dns_zone}."
  
  # Read certificate files from Exercise 25
  certificate_content = file(var.certificate_path)
  private_key_content = file(var.private_key_path)
}

# SSH Key
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-ssl-test-ssh-key"
  public_key = var.ssh_public_key

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Firewall
resource "hcloud_firewall" "server_firewall" {
  name = "${var.project}-ssl-test-firewall"

  # SSH access
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTP access
  rule {
    direction  = "in"
    port       = "80"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS access
  rule {
    direction  = "in"
    port       = "443"
    protocol   = "tcp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Outbound
  rule {
    direction       = "out"
    protocol        = "tcp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction       = "out"
    protocol        = "udp"
    port            = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# Server
resource "hcloud_server" "web_server" {
  name        = "${var.project}-ssl-test"
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  ssh_keys     = [hcloud_ssh_key.primary.id]
  firewall_ids = [hcloud_firewall.server_firewall.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    server_name         = var.dns_zone
    ssh_public_keys     = local.ssh_authorized_keys
    devops_username     = var.devops_username
    certificate_content = base64encode(local.certificate_content)
    private_key_content = base64encode(local.private_key_content)
    dns_zone            = var.dns_zone
  })

  lifecycle {
    create_before_destroy = true
  }
}

# DNS A record for the apex domain
resource "dns_a_record_set" "apex" {
  zone      = local.dns_zone_with_dot
  name      = "@"
  addresses = [hcloud_server.web_server.ipv4_address]
  ttl       = 10
}

# DNS A records for each server name (www, mail, etc.)
resource "dns_a_record_set" "names" {
  count     = length(var.server_names)
  zone      = local.dns_zone_with_dot
  name      = var.server_names[count.index]
  addresses = [hcloud_server.web_server.ipv4_address]
  ttl       = 10
}

# SSH wrapper
resource "local_file" "ssh_wrapper" {
  content = templatefile("${path.module}/tpl/ssh.sh", {
    devopsUsername = var.devops_username
    hostname       = var.dns_zone
  })

  filename        = "${path.module}/bin/ssh"
  file_permission = "0755"
}
