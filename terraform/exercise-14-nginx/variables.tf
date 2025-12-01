# Variables for Exercise 14 - Nginx Automation

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "nginx-server"
}

variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx22"
}

variable "server_image" {
  description = "Server operating system image"
  type        = string
  default     = "ubuntu-22.04"
}

variable "location" {
  description = "Server location"
  type        = string
  default     = "hel1"

  validation {
    condition = contains([
      "nbg1", "fsn1", "hel1", "ash", "hil"
    ], var.location)
    error_message = "Location must be a valid Hetzner Cloud location."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
  # Must be provided via terraform.tfvars or environment variable
}
