# 22 - Creating DNS Records

> **Working Code:** [`terraform/exercise-22-creating-dns-records/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-22-creating-dns-records/)

**The Problem:** Manually creating DNS records in a web UI is repetitive. Also, it's easy to make mistakes like creating duplicate records or pointing CNAMEs to themselves.

**The Solution:** Use Terraform to manage DNS records as code, with **validation** to catch errors before they apply.

## Objective
Create an architecture with:
1. `workhorse.g02...` (A Record) -> 1.2.3.4
2. `www.g02...` (CNAME) -> `workhorse`
3. `mail.g02...` (CNAME) -> `workhorse`
4. Validation to ensure no duplicates.

## How-to

### 1. Variables with Validation
You can tell Terraform to reject bad inputs:

```hcl
variable "server_aliases" {
  default = ["www", "mail"]

  validation {
    condition     = length(distinct(var.server_aliases)) == length(var.server_aliases)
    error_message = "Duplicate server alias names found."
  }
}
```

### 2. Creating multiple records
Use `count` or `for_each` to create multiple records from one resource block:

```hcl
resource "dns_cname_record" "aliases" {
  count = length(var.server_aliases)
  zone  = "sdi.hdm-stuttgart.cloud."
  name  = var.server_aliases[count.index]
  cname = "workhorse.g02.sdi.hdm-stuttgart.cloud."
}
```

## Troubleshooting: "Missing Resource State"
If Terraform says `Error: Missing Resource State After Create`, it means the DNS server accepted the request but didn't return the confirmation Terraform expected.

**Fix:** Import the record manually so Terraform knows about it:
```bash
terraform import 'dns_cname_record.aliases[0]' 'g02.sdi.hdm-stuttgart.cloud./www'
```

## Related Exercises
- [23 - Host with DNS](./23-host-with-dns.md) - Putting it all together (Server + DNS)
