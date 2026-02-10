# 28 - Subnets & Private Networking

> **Working Code:** [`terraform/exercise-28-subnet/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-28-subnet/)

**The Problem:** Giving every server a public IP is a security risk. Database servers should never be directly accessible from the internet.

**The Solution:** Create a private network. Use a Gateway (Jump Host) for access.

## Objective
Deploy network (`10.0.0.0/8`) and subnet (`10.0.1.0/24`) with:
- **Gateway:** Public IP + Private IP (`10.0.1.2`)
- **Internal:** Private IP only (`10.0.1.3`)

## Network Architecture

```
Internet
   |
   v
[ Gateway ] (Public + 10.0.1.2)
   |
   +--- [ Internal ] (10.0.1.3 only)
```

## How-to

### 1. Define Network
```hcl
resource "hcloud_network" "net" {
  name     = "private-net"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
```

### 2. Internal Server (No Public IP)
```hcl
resource "hcloud_server" "internal" {
  name = "internal"

  public_net {
    ipv4_enabled = false  # Isolated!
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.net.id
    ip = "10.0.1.3"
  }
}
```

### 3. Access via Gateway
```bash
# ProxyJump (recommended)
ssh -J devops@<gateway-ip> devops@10.0.1.3

# Manual hop
ssh devops@<gateway-ip>
ssh devops@10.0.1.3
```

## Problems & Learnings
**No Internet:** Internal server can't run `apt update` — it has no internet access.
**Fix:** Add NAT Gateway or Proxy (see Exercise 29).

## Related Exercises
- [29 - Application Gateway](./29-app-gateway.md)
