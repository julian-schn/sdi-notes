# Terraform Modules

This directory contains **reusable Terraform modules** that can be used across different exercises and projects.

## Available Modules

### host_metadata

Generates a JSON metadata file for a host with its network and location information.

**Location:** `modules/host_metadata/`

**Usage:**

```hcl
module "host_metadata" {
  source = "./modules/host_metadata"

  name     = "server-1"
  ipv4     = "123.45.67.89"
  ipv6     = "2001:db8::1"
  location = "nbg1"
}
```

**Inputs:**

- `name` (string) - Name of the host
- `ipv4` (string) - IPv4 address
- `ipv6` (string) - IPv6 address
- `location` (string) - Location/datacenter

**Outputs:**

- `filename` - Path to the generated metadata JSON file

**Generated File Example (`gen/<name>.json`):**

```json
{
  "ipv4": "123.45.67.89",
  "ipv6": "2001:db8::1",
  "location": "nbg1"
}
```

**Used in:**

- Exercise 17 - Host Metadata Generation

---

### SshKnownHosts

Generates deployment-scoped `known_hosts` file and SSH/SCP wrapper scripts for a server.

**Location:** `modules/SshKnownHosts/`

**Inputs:**

- `server_ip` (string) - Public IP address of the server
- `devops_username` (string) - Username for SSH access

**Outputs:**

- `ssh_wrapper_path` - Path to the generated SSH wrapper script
- `scp_wrapper_path` - Path to the generated SCP wrapper script

**Used in:**

- Exercise 16 - Known Hosts
- Exercise 17 - Host Metadata Generation
- Exercise 18+ (all subsequent exercises)

---

## Using Modules

Reference modules using relative paths:

```hcl
module "example" {
  source = "./modules/host_metadata"
  # ... inputs
}
```
