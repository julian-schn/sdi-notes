# Exercise 26 - Testing Your Web Certificate
# Creates a server with Nginx SSL using certificate from Exercise 25

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
provider "hcloud" {}

# Configure the DNS provider for HDM Stuttgart DNS server
provider "dns" {
  update {
    server        = "ns1.sdi.hdm-stuttgart.cloud"
    key_name      = "${var.project}.key."
    key_algorithm = "hmac-sha512"
    key_secret    = var.dns_secret
  }
}

provider "null" {}
provider "local" {}
