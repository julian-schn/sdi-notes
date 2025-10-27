# Terraform Configuration

This guide covers the structure and components of the Hetzner Cloud Terraform configuration.

## File Organization

The configuration is organized into focused files:

```
terraform/
├── main.tf          # Provider and Terraform settings
├── variables.tf     # Input variable definitions  
├── resources.tf     # Infrastructure resources
├── outputs.tf       # Output value definitions
└── terraform.tfvars # Variable assignments
```

## Provider Configuration

### Terraform Requirements

The `main.tf` file specifies Terraform and provider requirements:

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.46"
    }
  }
}
```

### Provider Setup

The Hetzner Cloud provider is configured to read credentials from environment variables:

```hcl
provider "hcloud" {
  # Token automatically read from HCLOUD_TOKEN environment variable
}
```

## Variable Definitions

Variables are defined in `variables.tf` with types, descriptions, and validation rules.

### Server Configuration Variables

```hcl
variable "server_type" {
  description = "Server type/size"
  type        = string
  default     = "cx22"

  validation {
    condition = contains([
      "cx11", "cx21", "cx22", "cx31", "cx32", "cx41", "cx42", "cx51", "cx52"
    ], var.server_type)
    error_message = "Server type must be a valid Hetzner Cloud server type."
  }
}
```

### Location Validation

```hcl
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
```

### SSH Key Variables

```hcl
variable "ssh_public_key" {
  description = "Primary SSH public key for server access"
  type        = string
  # No default - must be provided via environment variable
}

variable "ssh_public_key_secondary" {
  description = "Secondary SSH public key for server access (optional)"
  type        = string
  default     = ""
}
```

## Resource Configuration

### SSH Key Resources

Primary SSH key resource:

```hcl
resource "hcloud_ssh_key" "primary" {
  name       = "${var.project}-primary-ssh-key"
  public_key = var.ssh_public_key
  
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    key_type    = "primary"
  }
}
```

Secondary SSH key resource (conditional):

```hcl
resource "hcloud_ssh_key" "secondary" {
  count      = var.ssh_public_key_secondary != "" ? 1 : 0
  name       = "${var.project}-secondary-ssh-key"
  public_key = var.ssh_public_key_secondary
  
  labels = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    key_type    = "secondary"
  }
}
```

### Firewall Configuration

The firewall resource defines security rules:

```hcl
resource "hcloud_firewall" "server_firewall" {
  name = "${var.project}-firewall"
  
  # SSH access rule
  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  # Outbound traffic rules
  rule {
    direction      = "out"
    protocol       = "tcp"
    port          = "1-65535"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
```

### Server Resource

The main server resource with comprehensive configuration:

```hcl
resource "hcloud_server" "main_server" {
  name         = local.server_name
  image        = var.server_image
  server_type  = var.server_type
  location     = var.location
  
  # SSH key assignment
  ssh_keys = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )
  
  # Firewall assignment
  firewall_ids = [hcloud_firewall.server_firewall.id]
  
  # Network configuration
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  
  # Server initialization
  user_data = <<-EOF
    #!/bin/bash
    apt-get update && apt-get upgrade -y
    apt-get install -y curl wget git htop vim ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw --force enable
    echo "$(date): Server initialization completed" >> /var/log/user-data.log
  EOF
}
```

## Data Sources

Data sources fetch information about existing infrastructure:

```hcl
data "hcloud_servers" "existing" {}
```

This data source is used for auto-incrementing server names.

## Local Values

Local values compute derived data:

```hcl
locals {
  existing_server_numbers = [
    for server in data.hcloud_servers.existing.servers : 
    tonumber(regex("^${var.server_base_name}-(\\d+)$", server.name)[0])
    if can(regex("^${var.server_base_name}-(\\d+)$", server.name))
  ]
  next_server_number = length(local.existing_server_numbers) > 0 ? max(local.existing_server_numbers...) + 1 : 1
  server_name = "${var.server_base_name}-${local.next_server_number}"
}
```

This logic:
- Scans existing servers for naming pattern matches
- Extracts numeric suffixes from server names
- Calculates the next available number
- Generates the new server name

## Output Values

Outputs provide information about created resources:

```hcl
output "server_public_ipv4" {
  description = "Public IPv4 address of the server"
  value       = hcloud_server.main_server.ipv4_address
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh root@${hcloud_server.main_server.ipv4_address}"
}

output "ssh_keys_deployed" {
  description = "List of SSH key IDs deployed to the server"
  value = concat(
    [hcloud_ssh_key.primary.id],
    var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
  )
}
```

## Resource Labels

All resources include consistent labeling for management:

```hcl
labels = {
  environment = var.environment
  project     = var.project
  managed_by  = "terraform"
}
```

## Conditional Logic

The configuration uses conditional expressions for optional resources:

```hcl
# Conditional resource creation
count = var.ssh_public_key_secondary != "" ? 1 : 0

# Conditional list concatenation
ssh_keys = concat(
  [hcloud_ssh_key.primary.id],
  var.ssh_public_key_secondary != "" ? [hcloud_ssh_key.secondary[0].id] : []
)
```

## Lifecycle Management

Resources include lifecycle rules for safe operations:

```hcl
lifecycle {
  create_before_destroy = true
  prevent_destroy       = false
}
```