# Exercise 14 - Nginx Automation

> **Full Guide:** [docs/exercises/14-nginx-automation.md](../../docs/exercises/14-nginx-automation.md)

## Quick Start

```bash
make E=14 setup && make E=14 apply
# or: terraform init && terraform apply
```

## Verification

```bash
curl http://$(terraform output -raw server_ip)
```

## Cleanup

```bash
make E=14 destroy
```
