# 29 - Adding an Application Level Gateway

> **Working Code:** [`terraform/exercise-29-app-gateway/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-29-app-gateway/)

## Overview
Extend the subnet from Exercise 28 by adding an **apt-cacher-ng** HTTP proxy on the gateway server, enabling the isolated internal server to install and update packages through the proxy.

## Prerequisites
- Completed [Exercise 28 - Subnet](./28-subnet.md)
- Understanding of HTTP proxies
- Familiarity with APT package management configuration

## Objective
Solve the package management problem from Exercise 28: the internal server has no internet access, so it cannot install or update packages. The gateway runs `apt-cacher-ng` on port `3142`, and the intern server is configured to route all APT traffic through this proxy.

## Implementation

### Network Architecture

```
Internet
   │
   ▼
┌──────────────────────┐     ┌──────────────────────┐
│      Gateway         │     │   Private Network    │
│    (Public IP)       │     │   10.0.1.0/24        │
│    10.0.1.20         ├─────┤                      │
│                      │     │   ┌──────────────┐   │
│  ┌────────────────┐  │     │   │   Intern     │   │
│  │ apt-cacher-ng  │  │◄────┼───│  10.0.1.30   │   │
│  │  :3142         │  │     │   │ APT → proxy  │   │
│  └────────────────┘  │     │   └──────────────┘   │
└──────────────────────┘     └──────────────────────┘
```

### Step 1: Gateway — apt-cacher-ng Setup
The gateway's cloud-init installs and configures `apt-cacher-ng`:

```yaml
packages:
  - apt-cacher-ng

write_files:
  - path: /etc/apt-cacher-ng/zz_local.conf
    content: |
      BindAddress: 10.0.1.20
      Port: 3142
      CacheDir: /var/cache/apt-cacher-ng
      ExThreshold: 30
```

Key configuration: the proxy **only binds to the private interface** (`10.0.1.20`), ensuring it's not exposed to the internet.

### Step 2: Gateway Firewall
The UFW rules allow `apt-cacher-ng` traffic from the private subnet:

```bash
ufw allow from 10.0.1.0/24 to any port 3142 proto tcp
```

### Step 3: Intern — APT Proxy Configuration
The intern server configures APT to use the gateway proxy in two places for reliability:

1. **Cloud-init `apt` directive** — applies before any `package_update` operations:
   ```yaml
   apt:
     conf: |
       Acquire::http::Proxy "http://10.0.1.20:3142";
   ```

2. **Persistent config file** — ensures the proxy survives reboots:
   ```yaml
   write_files:
     - path: /etc/apt/apt.conf.d/02proxy
       content: |
         Acquire::http::Proxy "http://10.0.1.20:3142";
   ```

### Step 4: Service Readiness
The intern's cloud-init waits for the proxy to become available before attempting package operations:

```bash
timeout 300 bash -c 'until nc -z 10.0.1.20 3142; do sleep 5; done'
```

This handles the race condition where the intern boots before `apt-cacher-ng` is ready on the gateway.

### Step 5: Primary IP
Exercise 29 adds a `hcloud_primary_ip` resource for the gateway, ensuring a stable public IP that persists across server recreation:

```hcl
resource "hcloud_primary_ip" "gateway_ip" {
  name          = "${var.project}-gateway-ip"
  type          = "ipv4"
  auto_delete   = false
}
```

## Verification
1. Apply configuration: `terraform apply`
2. SSH to gateway and verify apt-cacher-ng is running:
   ```bash
   ssh devops@$(terraform output -raw gateway_ipv4_address)
   sudo systemctl status apt-cacher-ng
   ```
3. Verify proxy is listening on the private interface:
   ```bash
   ss -tlnp | grep 3142
   ```
4. SSH to intern from gateway and test package management:
   ```bash
   ssh devops@intern
   sudo apt-get update    # Should succeed via proxy
   ```
5. Verify proxy is being used (on gateway, check logs):
   ```bash
   sudo tail -f /var/log/apt-cacher-ng/apt-cacher.log
   ```
6. Confirm intern still has no direct internet:
   ```bash
   ping -c 1 8.8.8.8     # Should fail
   ```

## Problems & Learnings

::: warning Common Issues
- **Race condition:** The intern may boot before `apt-cacher-ng` is ready — the cloud-init `nc -z` wait loop handles this
- **Proxy binding:** `apt-cacher-ng` must bind to the private IP (`10.0.1.20`), not `0.0.0.0`, to avoid exposing the cache to the internet
- **Dual proxy config:** APT needs the proxy in both the cloud-init `apt:` section (for initial boot) and `/etc/apt/apt.conf.d/02proxy` (for persistence)
:::

::: tip Key Takeaways
- Application-level gateways (HTTP proxies) provide internet access to isolated hosts without breaking network isolation
- `apt-cacher-ng` also caches packages, reducing bandwidth for repeated installs across internal hosts
- The cloud-init `apt:` directive applies before `package_update`, which is essential for the proxy to work during initial provisioning
- Use `hcloud_primary_ip` when you need stable public IPs that survive `terraform destroy` and recreation cycles
:::

## Related Exercises
- [28 - Subnet](./28-subnet.md) - Base private network setup
- [15 - Cloud Init](./15-cloud-init.md) - Cloud-init fundamentals
- [27 - Combined Setup](./27-combined-setup.md) - Another multi-resource deployment
