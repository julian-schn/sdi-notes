# Exercise 24 - Creating a Fixed Number of Servers
# Providers configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.46"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.4"
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

# Configure the DNS provider for HDM Stuttgart DNS server
provider "dns" {
  update {
    server        = "ns1.sdi.hdm-stuttgart.cloud"
    key_name      = "${var.project}.key."
    key_algorithm = "hmac-sha512"
    key_secret    = var.dns_secret
  }
}

# Local provider (used for generating helper scripts/files)
provider "local" {}

# Null provider (used for local-exec helpers)
provider "null" {}
