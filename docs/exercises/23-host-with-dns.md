# 23 - Host with DNS

> **Working Code:** [`terraform/exercise-23-dns-host/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-23-dns-host/)

**The Problem:** In Exercise 16, we fixed "Unknown Host" by scanning the IP. But if you recreate the server, the IP changes and you must find the new one.

**The Solution:** Use a DNS name (e.g., `workhorse.g2...`) for SSH. The name stays the same even if the IP changes.

## Objective
Update SSH wrapper and `known_hosts` to use the server's DNS name instead of IP.

## How-to

### 1. Create DNS Record
```hcl
resource "dns_a_record_set" "workhorse" {
  zone = "sdi.hdm-stuttgart.cloud."
  name = "workhorse.g2"
  addresses = [hcloud_server.workhorse.ipv4_address]
}
```

### 2. Update ssh-keyscan
```hcl
provisioner "local-exec" {
  command = <<EOT
    sleep 10  # DNS propagation
    ssh-keyscan workhorse.g2.sdi.hdm-stuttgart.cloud > gen/known_hosts
  EOT
}
```

### 3. Update Wrapper Template
```bash
#!/bin/bash
ssh -o UserKnownHostsFile=gen/known_hosts devops@workhorse.g2.sdi.hdm-stuttgart.cloud "$@"
```

## Verification
```bash
terraform apply
./bin/ssh  # Connects via hostname
# Destroy/recreate → IP changes but ./bin/ssh still works
```

## Related Exercises
- [24 - Multiple Servers](./24-multiple-servers.md)
