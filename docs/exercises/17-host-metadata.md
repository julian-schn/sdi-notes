# 17 - Host Metadata Generation

> **Working Code:** [`terraform/exercise-17-host-metadata/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-17-host-metadata/)

## Overview
Implement module-based host creation that automatically generates a metadata JSON file for each host. This demonstrates Terraform module composition and file generation.

## Prerequisites
- Understanding of Terraform modules
- Familiarity with `templatefile` function
- Basic JSON syntax knowledge

## Objective
A root module `CreateHostByModule` calls a reusable `host_metadata` module. The `host_metadata` module uses `templatefile` to render a JSON file from variables. The generated file is saved to a `Gen/` directory with the host's name.

## Implementation

### Step 1: Create the Host Metadata Module
Create the module structure:

```hcl
# modules/host_metadata/variables.tf
variable "name" { type = string }
variable "ipv4" { type = string }
variable "ipv6" { type = string }
variable "location" { type = string }

# modules/host_metadata/tpl/hostdata.json
{
  "ipv4": "${ip4}",
  "ipv6": "${ip6}",
  "location": "${location}"
}

# modules/host_metadata/main.tf
resource "local_file" "hostdata" {
  content = templatefile("${path.module}/tpl/hostdata.json", {
      ip4      = var.ipv4
      ip6      = var.ipv6
      location = var.location
  })
  filename = "Gen/${var.name}.json"
}
```

### Step 2: Create the Root Module
Create a module that uses the host_metadata module:

```hcl
# CreateHostByModule/main.tf
module "host_metadata" {
  source = "../modules/host_metadata"

  name     = var.name
  ipv4     = "192.168.1.10"
  ipv6     = "2001:db8::1"
  location = "fsn1"
}

# CreateHostByModule/variables.tf
variable "name" {
  type    = string
  default = "web-server-01"
}
```

### Step 3: Initialize and Plan
Initialize the Terraform module:

```bash
cd terraform/CreateHostByModule
terraform init
```

Generate a plan:
```bash
terraform plan
```

## Verification
1. Navigate to module directory: `cd terraform/CreateHostByModule`
2. Initialize: `terraform init`
3. Plan: `terraform plan`
4. Verify output shows `Gen/web-server-01.json` will be created
5. Apply: `terraform apply`
6. Check file exists: `cat Gen/web-server-01.json`
7. Verify JSON content is correct

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [18 - SSH Module](./18-ssh-module.md) - More advanced module refactoring
- [24 - Multiple Servers](./24-multiple-servers.md) - Creating multiple hosts with modules
