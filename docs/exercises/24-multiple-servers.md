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

## Problems & Learnings

::: warning Common Issues
- **DNS propagation delay**: `ssh-keyscan` on the FQDN (`work-1.g2.sdi.hdm-stuttgart.cloud`) times out because DNS hasn't propagated yet when Terraform runs `null_resource.known_hosts`. Fix: scan by IP, then rewrite the entry with `sed` to use the FQDN.
- **macOS DNS resolution**: Even after propagation, macOS's system resolver (`getaddrinfo`) may not resolve the Hetzner DNS entries that `dig` can resolve. The SSH wrapper connects by IP with `-o HostKeyAlias=<fqdn>` so the correct known_hosts entry is matched.
:::

::: tip Key Takeaways
- Always scan SSH host keys by IP during provisioning — DNS is not yet reliable at that stage.
- Use `HostKeyAlias` to verify against a FQDN known_hosts entry while connecting by IP.
:::

## Related Exercises
- [28 - Subnet](./28-subnet.md)
