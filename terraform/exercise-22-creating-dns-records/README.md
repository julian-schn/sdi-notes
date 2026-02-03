# Exercise 22 - Creating DNS Records

> **Full Guide:** [docs/exercises/22-creating-dns-records.md](../../docs/exercises/22-creating-dns-records.md)

## Quick Start

```bash
make E=22 setup && make E=22 apply
```

## Known Issue: CNAME Import Required

DNS provider doesn't return state after creating CNAMEs. Manually import:

```bash
terraform import 'dns_cname_record.aliases["www"]' www.g2.sdi.hdm-stuttgart.cloud.
terraform import 'dns_cname_record.aliases["mail"]' mail.g2.sdi.hdm-stuttgart.cloud.
```

## Verification

```bash
dig www.g2.sdi.hdm-stuttgart.cloud @ns1.sdi.hdm-stuttgart.cloud
```

## Cleanup

```bash
make E=22 destroy
```
