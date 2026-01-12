# Variables for Exercise 15 - Cloud-init Configuration

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "cloud-init-server"
}

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx23"
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
  description = "Project name"
  type        = string
  default     = "cloud-init-demo"
}
