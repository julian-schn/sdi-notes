# 24 - Multiple Servers

> **Working Code:** [`terraform/exercise-24-multi-server/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-24-multi-server/)

**The Problem:** Deploying 5 servers means copy-pasting the `hcloud_server` block 5 times. Tedious and hard to maintain.

**The Solution:** Use `count` to tell Terraform "Make X copies of this".

## Objective
Deploy configurable number of servers (e.g., 2) with DNS records (`work-1`, `work-2`) and SSH wrappers.

## How-to

### 1. Variables
```hcl
variable "server_count" {
  default = 2
}
```

### 2. Servers with count
```hcl
resource "hcloud_server" "workers" {
  count = var.server_count
  name = "work-${count.index + 1}"  # work-1, work-2...
  # ...
}
```

### 3. DNS Records with count
```hcl
resource "dns_a_record_set" "workers" {
  count = var.server_count
  name = "work-${count.index + 1}"
  addresses = [hcloud_server.workers[count.index].ipv4_address]
}
```

### 4. SSH Modules with count
```hcl
module "ssh_config" {
  count = var.server_count
  source = "./modules/ssh_utils"

  name = hcloud_server.workers[count.index].name
  ip   = hcloud_server.workers[count.index].ipv4_address
}
```

## Verification
```bash
terraform apply
ls bin/  # See ssh-work-1, ssh-work-2
# Change server_count to 3 and apply again → one new server
```

## Related Exercises
- [28 - Subnet](./28-subnet.md)
