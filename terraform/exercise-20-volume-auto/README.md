# Exercise 20 - Volume Auto

> **Full Guide:** [docs/exercises/20-volume-auto.md](../../docs/exercises/20-volume-auto.md)

## Quick Start

```bash
make E=20 setup && make E=20 apply
```

## Verification

```bash
ssh devops@$(terraform output -raw server_ip)
df -h /mnt/data
cat /etc/fstab  # Verify persistent mount
```

## Cleanup

```bash
make E=20 destroy
```
