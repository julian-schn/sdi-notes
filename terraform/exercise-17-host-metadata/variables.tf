# Variables for Exercise 17 - Host Metadata Generation

variable "server_base_name" {
  description = "Base name for servers (auto-incremented)"
  type        = string
  default     = "server"
}

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx22"

  validation {
    condition = contains([
      "cx11", "cx21", "cx22", "cx23", "cx31", "cx32", "cx41", "cx42", "cx51", "cx52",
      "cpx11", "cpx21", "cpx31", "cpx41", "cpx51",
      "ccx11", "ccx12", "ccx13", "ccx21", "ccx22", "ccx23", "ccx31", "ccx32", "ccx33"
    ], var.server_type)
    error_message = "Server type must be a valid Hetzner Cloud server type."
  }
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
  default     = "hello-world"
}
