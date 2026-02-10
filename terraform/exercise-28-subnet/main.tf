# Exercise 28 - Creating a Subnet
# Creates a private network with two hosts: gateway (dual interface) and intern (private only)

data "hcloud_ssh_keys" "all" {}

# --- LOCAL VALUES ---

locals {
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

  ssh_authorized_keys = concat(
    [var.ssh_public_key],
    var.ssh_public_key_secondary != "" ? [var.ssh_public_key_secondary] : []
  )
}

# --- SSH KEYS ---

data "hcloud_ssh_key" "existing_primary" {
  count = var.existing_ssh_key_name != "" ? 1 : 0
  name  = var.existing_ssh_key_name
}

data "hcloud_ssh_key" "existing_secondary" {
  count = var.existing_ssh_key_secondary_name != "" ? 1 : 0
  name  = var.existing_ssh_key_secondary_name
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

# --- PRIVATE NETWORK ---

resource "hcloud_network" "private_net" {
  name     = "${var.project}-${var.private_network.name}"
  ip_range = var.private_network.ip_range

  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "cloud"
  network_zone = var.private_subnet.network_zone
  ip_range     = var.private_subnet.ip_and_netmask

  depends_on = [hcloud_network.private_net]
}

resource "hcloud_network_route" "gateway_route" {
  network_id  = hcloud_network.private_net.id
  destination = "0.0.0.0/0"
  gateway     = var.gateway_private_ip

  depends_on = [hcloud_network_subnet.private_subnet]
}

# --- FIREWALLS ---

# Gateway Firewall - SSH from Internet
resource "hcloud_firewall" "gateway_firewall" {
  name = "${var.project}-gateway-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
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

  rule {
    direction = "out"
    protocol  = "icmp"
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

# Internal Firewall - SSH from private network only
resource "hcloud_firewall" "intern_firewall" {
  name = "${var.project}-intern-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      var.private_subnet.ip_and_netmask
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

  rule {
    direction = "out"
    protocol  = "icmp"
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

# --- SERVERS ---

# Gateway Server - Dual interface (public + private)
resource "hcloud_server" "gateway" {
  name        = "${var.project}-gateway"
  server_type = var.server_type
  image       = var.os_type
  location    = var.location

  ssh_keys = local.ssh_key_ids

  firewall_ids = [hcloud_firewall.gateway_firewall.id]

  # Public interface
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Private interface
  network {
    network_id = hcloud_network.private_net.id
    ip         = var.gateway_private_ip
  }

  user_data = templatefile("${path.module}/cloud-init-gateway.yaml", {
    hostname            = "${var.project}-gateway"
    devops_username     = var.devops_username
    ssh_authorized_keys = local.ssh_authorized_keys
    dns_domain_name     = var.private_subnet.dns_domain_name
    gateway_private_ip  = var.gateway_private_ip
    intern_private_ip   = var.intern_private_ip
  })

  labels = {
    environment = var.environment
    project     = var.project
    role        = "gateway"
    managed_by  = "terraform"
  }

  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

# Internal Server - Private interface only
resource "hcloud_server" "intern" {
  name        = "${var.project}-intern"
  server_type = var.server_type
  image       = var.os_type
  location    = var.location

  ssh_keys = local.ssh_key_ids

  firewall_ids = [hcloud_firewall.intern_firewall.id]

  # Disable public interfaces
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  # Private interface only
  network {
    network_id = hcloud_network.private_net.id
    ip         = var.intern_private_ip
  }

  user_data = templatefile("${path.module}/cloud-init-intern.yaml", {
    hostname            = "${var.project}-intern"
    devops_username     = var.devops_username
    ssh_authorized_keys = local.ssh_authorized_keys
    dns_domain_name     = var.private_subnet.dns_domain_name
    gateway_private_ip  = var.gateway_private_ip
    intern_private_ip   = var.intern_private_ip
  })

  labels = {
    environment = var.environment
    project     = var.project
    role        = "internal"
    managed_by  = "terraform"
  }

  depends_on = [
    hcloud_network_subnet.private_subnet,
    hcloud_server.gateway
  ]
}
