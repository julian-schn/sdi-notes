# Exercise 13 - Base System

> **Full Guide:** [docs/exercises/13-base-system.md](../../docs/exercises/13-base-system.md)

## Quick Start

```bash
# Using Makefile
make E=base setup
make E=base apply

# Using Terraform
terraform init
cp config.auto.tfvars.example config.auto.tfvars
nano config.auto.tfvars
terraform apply
```

## Configuration

Edit `config.auto.tfvars`:

- `ssh_public_key` - Your SSH public key (required)
- `server_type` - Default: `cx33`
- `location` - Default: `nbg1`

## Outputs

- `server_ip` - IPv4 address for SSH access
- `server_ipv6` - IPv6 address  
- `server_datacenter` - Server location
- `server_status` - Should be "running"

## Cleanup

```bash
terraform destroy
```
