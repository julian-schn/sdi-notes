# 24 - Creating a Fixed Number of Servers

> **Working Code:** [`terraform/exercise-24-multi-server/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-24-multi-server/)

## Overview
Write a Terraform configuration for deploying a configurable number of servers with unique DNS entries and SSH configurations for each.

## Prerequisites
- Completed [Exercise 23 - Host with DNS](./23-host-with-dns.md)
- Understanding of Terraform count meta-argument
- Familiarity with dynamic resource creation

## Objective
Create multiple servers (defined by `serverCount`) with unique DNS entries and isolated SSH configurations per server.

## Implementation

### Configuration File
Define the deployment parameters in `config.auto.tfvars`:

```hcl
dnsZone        = "gxy.sdi.hdm-stuttgart.cloud"
serverBaseName = "work"
serverCount    = 2
```

### Expected Results
`terraform apply` shall create:

1. **Two DNS entries:**
   - `work-1.gxy.sdi.hdm-stuttgart.cloud`
   - `work-2.gxy.sdi.hdm-stuttgart.cloud`

2. **Two corresponding servers** each with its own unique SSH host key pair

3. **Two subdirectories** `work-1` and `work-2` each containing:
   - `bin/ssh` - SSH wrapper script for that specific server
   - `gen/known_hosts` - Known hosts file for that specific server

### Implementation Pattern
Use Terraform's `count` or `for_each` to create multiple instances of:
- Server resources
- DNS records
- SSH wrapper scripts
- Known hosts files

## Verification
1. Apply configuration: `terraform apply`
2. Verify DNS entries:
   ```bash
   dig +short work-1.gxy.sdi.hdm-stuttgart.cloud
   dig +short work-2.gxy.sdi.hdm-stuttgart.cloud
   ```
3. Verify directory structure:
   ```bash
   ls -la work-1/bin/ssh work-1/gen/known_hosts
   ls -la work-2/bin/ssh work-2/gen/known_hosts
   ```
4. Connect to each server:
   ```bash
   ./work-1/bin/ssh
   ./work-2/bin/ssh
   ```

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [23 - Host with DNS](./23-host-with-dns.md) - Single host with DNS setup
- [17 - Host Metadata](./17-host-metadata.md) - Module-based host creation
