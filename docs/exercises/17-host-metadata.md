# 17 - Host Metadata Generation

> **Working Code:** [`terraform/exercise-17-host-metadata/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-17-host-metadata/)

**The Problem:** You have other scripts (Ansible, monitoring) that need to know the IPs and names of your servers, but Terraform locks that info inside its state file.

**The Solution:** Have Terraform generate a JSON file for each server containing its metadata.

## Objective
Create a module that not only builds a server but also writes a `Gen/<hostname>.json` file with its details.

## How-to

### 1. The Module (`modules/host_metadata`)
This module takes input (IPs, location) and writes a file:

```hcl
# modules/host_metadata/main.tf
resource "local_file" "meta" {
  filename = "Gen/${var.name}.json"
  content  = jsonencode({
    ipv4     = var.ipv4
    ipv6     = var.ipv6
    location = var.location
  })
}
```

### 2. Calling the Module
In your main code, call this module for every server you create:

```hcl
module "web_metadata" {
  source = "./modules/host_metadata"
  
  name     = hcloud_server.web.name
  ipv4     = hcloud_server.web.ipv4_address
  location = hcloud_server.web.location
  # ... pass other vars
}
```

### 3. Result
After `terraform apply`, you'll have a `Gen/` folder full of JSON files that other tools can easily parse.

## Related Exercises
- [18 - SSH Module](./18-ssh-module.md) - Combining this with SSH logic
