# Terraform Basics

Terraform is an open-source infrastructure as code software tool that provides a
consistent CLI workflow to manage hundreds of cloud services.

## Core Concepts

### Providers

Providers are plugins for interacting with cloud APIs. For this course:

```hcl
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

provider "hcloud" {
  # reads HCLOUD_TOKEN from environment
}
```

### Resources

Each resource block maps to one infrastructure object.

```hcl
resource "hcloud_server" "web" {
  name        = "web-1"
  server_type = "cx33"
  image       = "debian-13"
  location    = "nbg1"
}
```

### Variables

Input variables serve as parameters for a Terraform module.

```hcl
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}
```

## Terraform Workflow

1. **Write** - Author infrastructure as code
2. **Plan** - Preview changes before applying
3. **Apply** - Provision reproducible infrastructure

```bash
terraform init
terraform plan
terraform apply
```

## State Management

Terraform keeps track of your real world infrastructure in a state file.
This state is used to create plans and make changes to your infrastructure.
