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

## Problems & Learnings

::: warning Common Issues
- **Terraform server creation takes 5+ minutes** — caused by `package_reboot_if_required: true` triggering a server reboot mid-provisioning. The Hetzner provider polls through the reboot. Set to `false`.
- **`Gen/web-server-01.json` not found** — the metadata file is named after the actual server (e.g. `Gen/metadata-server-1.json`). Use `terraform output -raw server_name` to get the correct name.
:::

::: tip Key Takeaways
- The metadata filename is dynamic — always use `terraform output -raw server_name` to reference it
- Auto-incrementing server names query existing Hetzner servers at plan time, so the name is only known after apply
:::

## Related Exercises
- [18 - SSH Module](./18-ssh-module.md)
