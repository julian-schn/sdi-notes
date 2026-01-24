# 23 - Creating a Host with Corresponding DNS Entries

> **Working Code:** [`terraform/exercise-23-dns-host/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-23-dns-host/)

## Overview
Extend Exercise 16 by adding DNS records like in Exercise 22. The provider-generated IPv4 address shall be bound to `workhorse` within your given zone. Use DNS names instead of IP addresses in generated SSH files.

## Prerequisites
- Completed [Exercise 16 - SSH Known Hosts](./16-ssh-known-hosts.md)
- Completed [Exercise 22 - Creating DNS Records](./22-creating-dns-records.md)
- Understanding of DNS resolution

## Objective
Use the server's common DNS name rather than its IP in the generated `gen/known_hosts`, `bin/ssh` and `bin/scp` files.

## Implementation

### Step 1: Update known_hosts with DNS Name
Update the `gen/known_hosts` file to use DNS name instead of IP:

**`gen/known_hosts`:**
```text
workhorse.gxy.sdi.hdm-stuttgart.cloud ssh-ed25519 AAAAC3N...at8e8JL3rr
```

### Step 2: Update SSH Wrapper
Update `bin/ssh` to use DNS name:

**`bin/ssh`:**
```bash
#!/usr/bin/env bash

GEN_DIR=$(dirname "$0")/../gen

ssh -o UserKnownHostsFile="$GEN_DIR/known_hosts" devops@workhorse.gxy.sdi.hdm-stuttgart.cloud "$@"
```

### Step 3: Update Terraform Configuration
Modify your Terraform configuration to:
1. Create DNS A record for the server
2. Use DNS name in ssh-keyscan command
3. Pass DNS name to wrapper templates

## Verification
1. Apply Terraform: `terraform apply`
2. Check DNS resolution: `dig +short workhorse.gxy.sdi.hdm-stuttgart.cloud`
3. Verify known_hosts uses DNS name: `cat gen/known_hosts`
4. Verify SSH wrapper uses DNS name: `cat bin/ssh`
5. Connect using wrapper: `./bin/ssh`
6. Verify connection works via DNS name

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [16 - SSH Known Hosts](./16-ssh-known-hosts.md) - Original SSH wrapper implementation
- [22 - Creating DNS Records](./22-creating-dns-records.md) - DNS record creation
- [24 - Multiple Servers](./24-multiple-servers.md) - Scaling to multiple hosts
