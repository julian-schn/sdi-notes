# Exercise 27 - Combined Certificate

> **Full Guide:** [docs/exercises/27-combined-setup.md](../../docs/exercises/27-combined-setup.md)

## Quick Start

```bash
make E=27 setup && make E=27 apply
```

## Configuration

```hcl
use_production = false  # Test with staging first!
```

## Cleanup

```bash
make E=27 destroy
```
