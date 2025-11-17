# Terraform configuration for Hetzner Cloud infrastructure
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
