# Exercise 21 - Enhancing Web Server
# Sets up web server with Nginx and DNS records for TLS config

data "hcloud_firewalls" "existing" {
  with_selector = "project=${var.project},managed_by=terraform"
}

locals {
  existing_firewall = try(
    one([for fw in data.hcloud_firewalls.existing.firewalls : fw if fw.name == "${var.project}-firewall"]),
    null
  )
  should_create_firewall = local.existing_firewall == null
  firewall_id = local.should_create_firewall ? hcloud_firewall.server_firewall[0].id : local.existing_firewall.id
}

# Create Firewall (HTTP/HTTPS/SSH)
resource "hcloud_firewall" "server_firewall" {
  count = local.should_create_firewall ? 1 : 0
  name  = "${var.project}-firewall"

  # SSH
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }
  
  rule {
    direction = "out"
    protocol  = "udp"
    port      = "1-65535"
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# SSH Config
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-primary-ssh-key-21" # Unique name to avoid conflict if sharing state
  public_key = var.ssh_public_key
  labels = {
    environment = var.environment
    project     = var.project
  }
}

resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key-21"
  public_key = var.ssh_public_key_secondary
  labels = {
    environment = var.environment
    project     = var.project
  }
}

locals {
  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
}

# Server
resource "hcloud_server" "web_server" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location

  ssh_keys = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )

  firewall_ids = [local.firewall_id]

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
    server_name     = var.server_name
    ssh_public_keys = local.ssh_authorized_keys
    devops_username = var.devops_username
  })
}

# DNS Configuration
data "hetznerdns_zone" "sdi" {
  name = var.dns_zone
}

# Record: g02.sdi...
resource "hetznerdns_record" "root" {
  zone_id = data.hetznerdns_zone.sdi.id
  name    = var.project # "g02"
  value   = hcloud_server.web_server.ipv4_address
  type    = "A"
  ttl     = 3600
}

# Record: www.g02.sdi...
resource "hetznerdns_record" "www" {
  zone_id = data.hetznerdns_zone.sdi.id
  name    = "www.${var.project}" # "www.g02"
  value   = hcloud_server.web_server.ipv4_address
  type    = "A"
  ttl     = 3600
}
