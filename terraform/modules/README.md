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

Module for managing SSH known_hosts entries (if implemented).

**Location:** `modules/SshKnownHosts/`

**Status:** Check module directory for details

---

## Using Modules

### Local Modules

Reference modules from the same repository using relative paths:

```hcl
module "example" {
  source = "./modules/host_metadata"
  # ... inputs
}
```

### From Other Projects

Reference modules from this repository:

```hcl
module "example" {
  source = "../path/to/sdi-notes/terraform/modules/host_metadata"
  # ... inputs
}
```

### Module Best Practices

1. **Self-contained** - Modules should be independent and reusable
2. **Well-documented** - Include README.md in each module
3. **Versioned** - Use git tags for module versions
4. **Tested** - Test modules independently
5. **Variables** - Use descriptive variable names and descriptions
6. **Outputs** - Expose useful values for consumption

## Creating New Modules

Structure for a new module:

```
modules/
└── module/
    ├── README.md          # Module documentation
    ├── main.tf            # Main resources
    ├── variables.tf       # Input variables
    ├── outputs.tf         # Output values
    ├── versions.tf        # Provider version constraints
    └── examples/          # Usage examples
        └── basic/
            └── main.tf
```

## Learn More

- [Terraform Modules Documentation](https://developer.hashicorp.com/terraform/language/modules)
- [Module Development](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Publishing Modules](https://developer.hashicorp.com/terraform/registry/modules/publish)
