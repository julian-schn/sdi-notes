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

::: warning CNAME Creation Requires Import Step

**Issue:** When running `terraform apply`, CNAME record creation fails with:

```
Error: Missing Resource State After Create
  with dns_cname_record.aliases["www"]
```

**Root Cause:** The HDM Stuttgart DNS server successfully creates the CNAME records but doesn't return proper state to the Terraform DNS provider. This is a known limitation of the DNS infrastructure.

**Evidence the CNAMEs were created:**

```bash
# Verify records exist despite the error
dig +short www.g2.sdi.hdm-stuttgart.cloud @ns1.sdi.hdm-stuttgart.cloud
dig +short mail.g2.sdi.hdm-stuttgart.cloud @ns1.sdi.hdm-stuttgart.cloud
```

**Required Workaround:**
After the `terraform apply` error, import the created CNAMEs:

```bash
terraform import 'dns_cname_record.aliases["www"]' 'g2.sdi.hdm-stuttgart.cloud./www'
terraform import 'dns_cname_record.aliases["mail"]' 'g2.sdi.hdm-stuttgart.cloud./mail'

# Verify Terraform now tracks them
terraform plan  # Should show "No changes"
```

**Why this matters:** Without importing, Terraform won't be able to manage or destroy these records properly.

:::

::: tip Key Takeaways

- **DNS provider limitations** can require manual intervention even with correct Terraform code
- **Always verify actual DNS state** with `dig` when Terraform reports errors
- **Import is a recovery tool** for resources created outside Terraform's tracking
- **CNAME validation rules** prevent common configuration mistakes (no duplicates, no self-references)
:::

## Related Exercises

- [21 - Enhancing Web Server](./21-enhancing-web-server.md) - DNS with web server setup
- [23 - Host with DNS](./23-host-with-dns.md) - Integrating DNS with server creation
