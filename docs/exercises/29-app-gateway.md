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
1. Apply configuration: `terraform apply`
2. SSH to gateway and verify apt-cacher-ng is running:
   ```bash
   ssh -A devops@$(terraform output -raw gateway_ipv4_address)
   sudo systemctl status apt-cacher-ng
   ss -tlnp | grep 3142   # Should show 10.0.1.20:3142
   ```
3. SSH to intern and test package management:
   ```bash
   ssh devops@intern
   sudo apt-get update    # Should succeed via proxy
   ping -c 1 8.8.8.8     # Should fail (no direct internet)
   ```
4. Verify proxy traffic on gateway:
   ```bash
   sudo tail -f /var/log/apt-cacher-ng/apt-cacher.log
   ```

## Problems & Learnings

::: warning Common Issues
- **`Permission denied` SSHing from gateway to intern:** Same as Exercise 28 — use `ssh -A` with agent forwarding. Run `ssh-add ~/.ssh/id_ed25519` first if the agent is empty.
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
- [28 - Subnet](./28-subnet.md)
