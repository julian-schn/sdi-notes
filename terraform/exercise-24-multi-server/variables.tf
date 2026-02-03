# Variables for Exercise 24 - Multi-Server

variable "server_base_name" {
  description = "Base name for servers (e.g., 'work' creates work-1, work-2, ...)"
  type        = string
  default     = "work"

  validation {
    condition     = length(trimspace(var.server_base_name)) > 0
    error_message = "server_base_name must not be empty."
  }
}

variable "server_count" {
  description = "Number of servers to create"
  type        = number
  default     = 2

  validation {
    condition     = var.server_count >= 1 && var.server_count <= 10
    error_message = "server_count must be between 1 and 10."
  }
}

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx33"
}

variable "server_image" {
  description = "Server operating system image"
  type        = string
  default     = "debian-13"
}

variable "location" {
  description = "Server location"
  type        = string
  default     = "nbg1"

  validation {
    condition = contains([
      "nbg1", "fsn1", "hel1", "ash", "hil"
    ], var.location)
    error_message = "Location must be a valid Hetzner Cloud location."
  }
}

variable "ssh_public_key" {
  description = "Primary SSH public key for server access"
  type        = string
}

variable "ssh_public_key_secondary" {
  description = "Secondary SSH public key for server access (optional)"
  type        = string
  default     = ""
}

variable "devops_username" {
  description = "Username for the DevOps account created via cloud-init"
  type        = string
  default     = "devops"

  validation {
    condition     = length(trimspace(var.devops_username)) > 0
    error_message = "devops_username must not be empty."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "project" {
  description = "Project/group name for DNS (e.g., g2)"
  type        = string
  default     = "g2"
}

variable "dns_zone" {
  description = "DNS zone name (e.g., g2.sdi.hdm-stuttgart.cloud)"
  type        = string
  default     = "g2.sdi.hdm-stuttgart.cloud"
}

variable "dns_secret" {
  description = "HMAC-SHA512 secret for HDM Stuttgart DNS"
  type        = string
  sensitive   = true
}

variable "existing_ssh_key_name" {
  description = "Name of existing primary SSH key in Hetzner Cloud to reuse (optional). If provided, no new primary SSH key will be created."
  type        = string
  default     = ""
}

variable "existing_ssh_key_secondary_name" {
  description = "Name of existing secondary SSH key in Hetzner Cloud to reuse (optional). If provided, no new secondary SSH key will be created."
  type        = string
  default     = ""
}
