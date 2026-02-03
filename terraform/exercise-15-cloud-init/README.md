# Exercise 15 - Cloud-init

> **Full Guide:** [docs/exercises/15-cloud-init.md](../../docs/exercises/15-cloud-init.md)

## Quick Start

```bash
make E=15 setup && make E=15 apply
```

## Verification

```bash
# SSH as devops user (not root!)
ssh devops@$(terraform output -raw server_ip)
sudo ufw status
curl http://$(terraform output -raw server_ip)
```

## Cleanup

```bash
make E=15 destroy
```
