# Exercise 24 - Multi-Server

> **Full Guide:** [docs/exercises/24-multiple-servers.md](../../docs/exercises/24-multiple-servers.md)

## Quick Start

```bash
make E=24 setup && make E=24 apply
```

## Configuration

- `server_count = 2` (adjustable)
- Creates `work-1`, `work-2`, etc.

## Verification

```bash
terraform state list | grep hcloud_server
ssh devops@work-1.g2.sdi.hdm-stuttgart.cloud
```

## Cleanup

```bash
make E=24 destroy
```
