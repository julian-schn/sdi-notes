# Exercise 23 - DNS Host

> **Full Guide:** [docs/exercises/23-host-with-dns.md](../../docs/exercises/23-host-with-dns.md)

## Quick Start

```bash
make E=23 setup && make E=23 apply
```

## Usage

```bash
# Use generated SSH wrapper
./bin/ssh

# Or direct SSH via DNS
ssh devops@workhorse.g2.sdi.hdm-stuttgart.cloud
```

## Cleanup

```bash
make E=23 destroy
```
