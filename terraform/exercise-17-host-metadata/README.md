# Exercise 17 - Host Metadata

> **Full Guide:** [docs/exercises/17-host-metadata.md](../../docs/exercises/17-host-metadata.md)

## Quick Start

```bash
make E=17 setup && make E=17 apply
```

## Generated Files

```bash
cat gen/host_metadata.json | jq .
```

## Cleanup

```bash
make E=17 destroy
```
