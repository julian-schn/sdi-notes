# Exercise 21 - Enhancing Web Server

> **Full Guide:** [docs/exercises/21-enhancing-web-server.md](../../docs/exercises/21-enhancing-web-server.md)

## Quick Start

```bash
make E=21 setup && make E=21 apply
```

## Configuration

- Uses `project = "g2"` (shared infrastructure)
- Part of DNS/Web Server sequence (21→22→23→24)

## Verification

```bash
curl http://$(terraform output -raw server_ip)
```

## Cleanup

```bash
make E=21 destroy
```
