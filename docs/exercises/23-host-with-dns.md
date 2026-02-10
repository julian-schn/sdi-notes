# 23 - Host with DNS

> **Working Code:** [`terraform/exercise-23-dns-host/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-23-dns-host/)

**The Problem:** In Exercise 16, we fixed the "Unknown Host" warning by scanning the IP. But if you destroy and recreate the server, the IP might change, and you have to find the new one.

**The Solution:** Use a **DNS Name** (e.g., `workhorse.g2...`) for SSH. The name stays the same even if the underlying IP changes.

## Objective
Update the SSH wrapper and `known_hosts` logic to use the server's DNS name instead of its IP.

## How-to

### 1. Terraform: Create the Record
Link the server's IP to a domain name:

```hcl
resource "dns_a_record_set" "workhorse" {
  zone = "sdi.hdm-stuttgart.cloud."
  name = "workhorse.g2"
  addresses = [hcloud_server.workhorse.ipv4_address]
}
```

### 2. Update `ssh-keyscan`
Scan the **name**, not the IP. Note the `sleep 10` — DNS propagation takes a moment!

```hcl
provisioner "local-exec" {
  command = <<EOT
    sleep 10 # Wait for DNS
    ssh-keyscan workhorse.g2.sdi.hdm-stuttgart.cloud > gen/known_hosts
  EOT
}
```

### 3. Update the Wrapper Template
Tell SSH to connect to the hostname:

```bash
#!/bin/bash
# bin/ssh
ssh -o UserKnownHostsFile=gen/known_hosts devops@workhorse.g2.sdi.hdm-stuttgart.cloud "$@"
```

## Verification
1. `terraform apply`
2. `./bin/ssh` -> Connects via hostname!
3. If you destroy/recreate, the IP changes, but `./bin/ssh` still works.

## Related Exercises
- [24 - Multiple Servers](./24-multiple-servers.md) - Doing this for many servers at once
