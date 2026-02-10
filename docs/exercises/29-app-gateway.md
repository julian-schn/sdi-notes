# 29 - Application Gateway (APT Proxy)

> **Working Code:** [`terraform/exercise-29-app-gateway/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-29-app-gateway/)

**The Problem:** The internal server from Exercise 28 can't run `apt update` — it has no internet access.

**The Solution:** Turn the Gateway into an APT proxy using `apt-cacher-ng`. Internal server fetches packages via gateway without full internet access.

## Objective
Configure Gateway with `apt-cacher-ng` on port `3142`, and configure Internal server to use it as proxy.

## Network Architecture

```
Internet
   |
   v
[ Gateway ] (Public IP + 10.0.1.2)
   |  ^
   |  | (APT :3142)
   v
[ Internal ] (10.0.1.3)
```

## How-to

### 1. Gateway: Install apt-cacher-ng
```yaml
# cloud-init.yaml
packages:
  - apt-cacher-ng

write_files:
  - path: /etc/apt-cacher-ng/zz_local.conf
    content: |
      BindAddress: 10.0.1.2
      Port: 3142

runcmd:
  - ufw allow from 10.0.1.0/24 to any port 3142 proto tcp
```

### 2. Internal: Use the Proxy
```yaml
# cloud-init.yaml
apt:
  proxy: "http://10.0.1.2:3142"

write_files:
  - path: /etc/apt/apt.conf.d/02proxy
    content: |
      Acquire::http::Proxy "http://10.0.1.2:3142";
```

### 3. Primary IP (Stability)
Use `hcloud_primary_ip` so gateway keeps the same IP across recreates:

```hcl
resource "hcloud_primary_ip" "gateway_ip" {
  name = "gateway-ip"
  type = "ipv4"
  assignee_type = "server"
}
```

## Verification
```bash
terraform apply
# SSH to Internal (via Gateway)
apt update  # Works!
ping 8.8.8.8  # Still fails (security maintained)
```

## Related Exercises
- [28 - Subnet](./28-subnet.md)
