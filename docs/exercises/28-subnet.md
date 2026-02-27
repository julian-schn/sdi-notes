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

### 4. Cloud-Init
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
2. SSH to gateway **with agent forwarding** so your key is available for the second hop:
   ```bash
   ssh -A devops@$(terraform output -raw gateway_ipv4_address)
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
- **`Permission denied (publickey)` when SSHing from gateway to intern**: The gateway doesn't hold your private key. Connect with `ssh -A` (agent forwarding) so the gateway can use your local key for the second hop. On macOS the agent is empty by default — run `ssh-add --apple-use-keychain ~/.ssh/id_ed25519` first.
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
- [29 - Application Gateway](./29-app-gateway.md)
