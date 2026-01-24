# 22 - Creating DNS Records

> **Working Code:** [`terraform/exercise-22-creating-dns-records/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-22-creating-dns-records/)

## Overview
Starting from a domain `g02.sdi.hdm-stuttgart.cloud`, use Terraform to create A records and CNAME aliases with proper validation to prevent configuration errors.

## Prerequisites
- Access to Hetzner DNS or similar DNS provider
- Understanding of DNS record types (A, CNAME)
- Familiarity with Terraform variables and validation

## Objective
Create an A record for `workhorse.g02...` resolving to `1.2.3.4`, an A record for apex `g02...`, and CNAME aliases `www` and `mail` referencing `workhorse`.

## Implementation

### Step 1: Variables with Validation
Create variables for flexibility with strict validation rules:

```hcl
# variables.tf
variable "server_name" {
  default = "workhorse"
}

variable "server_aliases" {
  default = ["www", "mail"]

  # Rule 1: No Duplicates
  validation {
    condition     = length(distinct(var.server_aliases)) == length(var.server_aliases)
    error_message = "Duplicate server alias names found."
  }

  # Rule 2: No Name Conflict
  validation {
    condition     = !contains(var.server_aliases, var.server_name)
    error_message = "Server alias name matches server's common name."
  }
}
```

### Step 2: Main Configuration
Use the standard `count` meta-argument to iterate over aliases:

```hcl
# main.tf
resource "hetznerdns_record" "aliases" {
  count = length(var.server_aliases)
  # ...
  name  = var.server_aliases[count.index]
  value = "${var.server_name}.${var.dns_zone}."
  type  = "CNAME"
}
```

This creates:
1. An A record `workhorse.g02...` resolving to `1.2.3.4`
2. An A record for `g02...` resolving to `1.2.3.4`
3. CNAME aliases `www` and `mail` both referencing `workhorse`

## Verification
Run `terraform apply` and verify with `dig`:

```bash
dig +noall +answer @ns1.hdm-stuttgart.cloud g02.sdi.hdm-stuttgart.cloud
dig +noall +answer @ns1.hdm-stuttgart.cloud workhorse.g02.sdi.hdm-stuttgart.cloud
dig +noall +answer @ns1.hdm-stuttgart.cloud www.g02.sdi.hdm-stuttgart.cloud
dig +noall +answer @ns1.hdm-stuttgart.cloud mail.g02.sdi.hdm-stuttgart.cloud
```

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [21 - Enhancing Web Server](./21-enhancing-web-server.md) - DNS with web server setup
- [23 - Host with DNS](./23-host-with-dns.md) - Integrating DNS with server creation
