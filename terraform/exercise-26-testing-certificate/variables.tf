# Variables for Exercise 26 - Testing Certificate

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "dns_secret" {
  description = "DNS update secret for RFC2136 dynamic DNS"
  type        = string
  sensitive   = true
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
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
}

variable "ssh_public_key_secondary" {
  description = "Optional secondary SSH public key (leave empty to skip)"
  type        = string
  default     = ""
}

variable "devops_username" {
  description = "Username for the devops user"
  type        = string
  default     = "devops"
}

variable "environment" {
  description = "Environment (development, staging, production)"
  type        = string
  default     = "development"
}

variable "project" {
  description = "Project name (matches DNS zone prefix)"
  type        = string
}

variable "dns_zone" {
  description = "DNS zone for the server (e.g., g2.sdi.hdm-stuttgart.cloud)"
  type        = string
}

variable "server_names" {
  description = "List of server hostname prefixes (e.g., ['www', 'mail'])"
  type        = list(string)
  default     = ["www", "mail"]
}

variable "email" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
    error_message = "Email must be a valid email address."
  }
}

variable "use_production" {
  description = "Use Let's Encrypt production environment (false = staging, will show browser warnings)"
  type        = bool
  default     = false

  validation {
    condition     = var.use_production == false || var.use_production == true
    error_message = "For safety, always start with staging (false). Set to true only after testing."
  }
}

variable "existing_ssh_key_name" {
  description = "Name of existing SSH key to reuse (leave empty to create new)"
  type        = string
  default     = ""
}

variable "existing_ssh_key_secondary_name" {
  description = "Name of existing secondary SSH key to reuse (leave empty to create new)"
  type        = string
  default     = ""
}
