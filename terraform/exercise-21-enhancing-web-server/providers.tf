terraform {
  required_version = ">= 1.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.46"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.2.0"
    }
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  # Token should be provided via HCLOUD_TOKEN env var
}

# Configure the Hetzner DNS Provider
provider "hetznerdns" {
  # Token should be provided via HETZNER_DNS_TOKEN env var
}
