# Exercise 29 - Variables

# --- PROJECT CONFIGURATION ---

variable "project" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ex29"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# --- HETZNER CLOUD CONFIGURATION ---

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
  default     = "nbg1" # Nuremberg
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
  default     = "cx22" # 2 vCPU, 4 GB RAM
}

variable "os_type" {
  description = "Operating system image"
  type        = string
  default     = "debian-13"
}

# --- SSH CONFIGURATION ---

variable "ssh_public_key" {
  description = "Primary SSH public key for server access"
  type        = string
}

variable "ssh_public_key_secondary" {
  description = "Secondary SSH public key (optional)"
  type        = string
  default     = ""
}

variable "devops_username" {
  description = "DevOps user name"
  type        = string
  default     = "devops"
}

# --- NETWORK CONFIGURATION ---

variable "private_network" {
  description = "Private network configuration"
  type = object({
    name     = string
    ip_range = string
  })
  default = {
    name     = "private-net"
    ip_range = "10.0.0.0/8"
  }
}

variable "private_subnet" {
  description = "Private subnet configuration"
  type = object({
    dns_domain_name = string
    ip_and_netmask  = string
    network_zone    = string
  })
  default = {
    dns_domain_name = "intern.g3.hdm-stuttgart.cloud"
    ip_and_netmask  = "10.0.1.0/24"
    network_zone    = "eu-central"
  }
}

variable "gateway_private_ip" {
  description = "Gateway host IP address on private network"
  type        = string
  default     = "10.0.1.20"

  validation {
    condition     = can(regex("^10\\.0\\.1\\.", var.gateway_private_ip))
    error_message = "Gateway IP must be within the 10.0.1.0/24 subnet"
  }
}

variable "intern_private_ip" {
  description = "Internal host IP address on private network"
  type        = string
  default     = "10.0.1.30"

  validation {
    condition     = can(regex("^10\\.0\\.1\\.", var.intern_private_ip))
    error_message = "Intern IP must be within the 10.0.1.0/24 subnet"
  }
}

variable "existing_ssh_key_name" {
  description = "Reuse existing primary SSH key by name (skips creation)"
  type        = string
  default     = ""
}

variable "existing_ssh_key_secondary_name" {
  description = "Reuse existing secondary SSH key by name (skips creation)"
  type        = string
  default     = ""
}
