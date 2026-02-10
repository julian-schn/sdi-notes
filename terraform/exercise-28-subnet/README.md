# Exercise 28 - Subnet

> **Full Guide:** [docs/exercises/28-subnet.md](../../docs/exercises/28-subnet.md)

## Quick Start

```bash
make E=28 setup && make E=28 apply
```

## Configuration

- Uses `project = "ex28"` (independent)
- Gateway: Public + Private (10.0.1.20)
- Intern: Private only (10.0.1.30)

## Verification

```bash
# SSH to gateway
ssh devops@$(terraform output -raw gateway_public_ip)

# From gateway, SSH to internal server
ssh devops@10.0.1.30
ping -c 3 1.1.1.1  # Test internet via gateway
```

## Cleanup

```bash
make E=28 destroy
```
