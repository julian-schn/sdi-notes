# Terraform Basics
(AI Slop here)

Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services.

## Core Concepts

### Providers

Providers are plugins that Terraform uses to interact with cloud providers, SaaS providers, and other APIs.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
```

### Resources

Resources are the most important element in the Terraform language. Each resource block describes one or more infrastructure objects.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
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

Terraform keeps track of your real world infrastructure in a state file. This state is used to create plans and make changes to your infrastructure.