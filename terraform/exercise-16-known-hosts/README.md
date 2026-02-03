# Exercise 16 - SSH Known Hosts

> **Full Guide:** [docs/exercises/16-ssh-known-hosts.md](../../docs/exercises/16-ssh-known-hosts.md)

## Quick Start

```bash
make E=16 setup && make E=16 apply
```

## Usage

```bash
# Use generated SSH wrapper (no warnings!)
./bin/ssh
./bin/scp file.txt remote:~/
```

## Cleanup

```bash
make E=16 destroy
```
