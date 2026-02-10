# 17 - Host Metadata Generation

> **Working Code:** [`terraform/exercise-17-host-metadata/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-17-host-metadata/)

**The Problem:** Other tools (Ansible, monitoring) need server IPs/names, but Terraform locks that in its state file.

**The Solution:** Terraform generates a JSON file for each server with its metadata.

## Objective
Create a module that builds a server and writes `Gen/<hostname>.json` with its details.

## How-to

### 1. The Module
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

### 2. Call the Module
```hcl
module "web_metadata" {
  source = "./modules/host_metadata"

  name     = hcloud_server.web.name
  ipv4     = hcloud_server.web.ipv4_address
  location = hcloud_server.web.location
}
```

### 3. Result
After `terraform apply`, `Gen/` folder contains JSON files for other tools to parse.

## Related Exercises
- [18 - SSH Module](./18-ssh-module.md)
