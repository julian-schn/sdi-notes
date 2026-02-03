# Exercise 19 - Volume Manual

> **Full Guide:** [docs/exercises/19-volume-manual.md](../../docs/exercises/19-volume-manual.md)

## Quick Start

```bash
make E=19 setup && make E=19 apply
```

## Verification

```bash
ssh devops@$(terraform output -raw server_ip)
lsblk
df -h /mnt/volume
```

## Cleanup

```bash
make E=19 destroy  # WARNING: Deletes volume and all data!
```
