# Exercise 29 - Application Gateway

> **Full Guide:** [docs/exercises/29-app-gateway.md](../../docs/exercises/29-app-gateway.md) *(if available)*

## Quick Start

```bash
make E=29 setup && make E=29 apply
```

## Configuration

- Gateway: apt-cacher-ng proxy (port 3142)
- Intern: Uses proxy for package management

## Verification

```bash
# SSH to gateway
ssh devops@$(terraform output -raw gateway_public_ip)
sudo systemctl status apt-cacher-ng

# SSH to intern
ssh devops@10.0.1.30
sudo apt-get update
# Check gateway logs: /var/log/apt-cacher-ng/apt-cacher.log
```

## Cleanup

```bash
make E=29 destroy
```
