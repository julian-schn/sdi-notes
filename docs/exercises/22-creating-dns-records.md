# 22 - Creating DNS Records

> **Working Code:** [`terraform/exercise-22-creating-dns-records/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-22-creating-dns-records/)

**The Problem:** Manually creating DNS records in a web UI is repetitive and error-prone (duplicates, CNAMEs pointing to themselves).

**The Solution:** Use Terraform to manage DNS as code with validation to catch errors.

## Objective
Create:
1. `workhorse.g02...` (A Record) → 1.2.3.4
2. `www.g02...` (CNAME) → `workhorse`
3. `mail.g02...` (CNAME) → `workhorse`
4. Validation to prevent duplicates

## How-to

### 1. Variables with Validation
```hcl
variable "server_aliases" {
  default = ["www", "mail"]

  validation {
    condition     = length(distinct(var.server_aliases)) == length(var.server_aliases)
    error_message = "Duplicate server alias names found."
  }
}
```

### 2. Multiple Records with for_each
```hcl
resource "dns_cname_record" "aliases" {
  for_each = toset(var.server_aliases)
  zone  = "sdi.hdm-stuttgart.cloud."
  name  = each.value
  cname = "workhorse.g02.sdi.hdm-stuttgart.cloud."
}
```

## Troubleshooting
**"Missing Resource State":** DNS server accepted the request but didn't return confirmation. Fix by importing manually:

```bash
terraform import 'dns_cname_record.aliases["www"]' 'g02.sdi.hdm-stuttgart.cloud./www'
```

## Related Exercises
- [23 - Host with DNS](./23-host-with-dns.md)
