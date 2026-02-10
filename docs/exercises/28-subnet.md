# 28 - Creating a Subnet

> **Working Code:** [`terraform/exercise-28-subnet/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-28-subnet/)

## Overview
Create a private network (subnet) in Hetzner Cloud with two hosts: a **gateway** server with both public and private interfaces, and an **internal** server reachable only via the private network.

## Prerequisites
- Completed [Exercise 24 - Multiple Servers](./24-multiple-servers.md)
- Understanding of private networking concepts (subnets, routing, NAT)
- Familiarity with cloud-init and Terraform dependency ordering

## Objective
Deploy a private `10.0.1.0/24` subnet with two servers:
- **Gateway** (`10.0.1.20`) — public + private interfaces, acts as the entry point
- **Intern** (`10.0.1.30`) — private interface only, no direct internet access

## Implementation

### Network Architecture

```
Internet
   │
   ▼
┌──────────────┐     ┌──────────────────────┐
│   Gateway    │     │   Private Network    │
│  (Public IP) ├─────┤   10.0.1.0/24        │
│  10.0.1.20   │     │                      │
└──────────────┘     │   ┌──────────────┐   │
                     │   │   Intern     │   │
                     │   │  10.0.1.30   │   │
                     │   │  (no public) │   │
                     │   └──────────────┘   │
                     └──────────────────────┘
```

### Step 1: Network Resources
The configuration creates three network-level resources:

```hcl
# Private network (10.0.0.0/8 supernet)
resource "hcloud_network" "private_net" { ... }

# Subnet within the network (10.0.1.0/24)
resource "hcloud_network_subnet" "private_subnet" { ... }

# Default route via gateway for internal hosts
resource "hcloud_network_route" "gateway_route" {
  destination = "0.0.0.0/0"
  gateway     = var.gateway_private_ip
}
```

### Step 2: Firewalls
Two separate firewalls enforce network isolation:

- **Gateway firewall** — allows SSH from the internet (`0.0.0.0/0`)
- **Intern firewall** — allows SSH only from the private subnet (`10.0.1.0/24`)

### Step 3: Server Configuration
The gateway has both public and private interfaces:

```hcl
public_net {
  ipv4_enabled = true
  ipv6_enabled = true
}
network {
  network_id = hcloud_network.private_net.id
  ip         = var.gateway_private_ip  # 10.0.1.20
}
```

The intern server has **no public interface**:

```hcl
public_net {
  ipv4_enabled = false
  ipv6_enabled = false
}
network {
  network_id = hcloud_network.private_net.id
  ip         = var.intern_private_ip  # 10.0.1.30
}
```

### Step 4: Cloud-Init
Both servers use cloud-init for:
- SSH hardening (no passwords, no root login)
- UFW firewall configuration
- Custom `/etc/hosts` template for private DNS resolution (`gateway` and `intern` hostnames)

The gateway additionally installs **fail2ban** for intrusion prevention.

::: tip Internal Server Limitations
The intern server has `package_update: false` because it has no internet access. Package management requires the application gateway from [Exercise 29](./29-app-gateway.md).
:::

## Verification
1. Apply configuration: `terraform apply`
2. SSH to gateway:
   ```bash
   ssh devops@$(terraform output -raw gateway_ipv4_address)
   ```
3. From gateway, SSH to intern via hostname:
   ```bash
   ssh devops@intern
   ```
4. Verify intern has no internet:
   ```bash
   ping -c 3 1.1.1.1  # Should fail (no route to internet)
   ```
5. Verify private connectivity:
   ```bash
   ping -c 3 gateway  # Should succeed from intern
   ```

## Problems & Learnings

::: warning Common Issues
- The intern server **cannot install packages** or run updates — this is by design and is resolved in [Exercise 29](./29-app-gateway.md)
- Ensure proper `depends_on` ordering: subnet must exist before servers, gateway must exist before intern
- Hetzner Cloud requires a network route (`0.0.0.0/0 → gateway`) for internal traffic forwarding
:::

::: tip Key Takeaways
- Use separate firewalls per role to enforce least-privilege network access
- Cloud-init `manage_etc_hosts: template` enables custom hostname resolution across the private network
- Disabling public interfaces (`ipv4_enabled = false`) provides true network isolation
:::

## Related Exercises
- [24 - Multiple Servers](./24-multiple-servers.md) - Multi-server deployment pattern
- [29 - Application Gateway](./29-app-gateway.md) - Adds HTTP proxy for package management
- [15 - Cloud Init](./15-cloud-init.md) - Cloud-init fundamentals
