# Exercise 25 - Web Certificate

> **Full Guide:** [docs/exercises/25-web-certificate.md](../../docs/exercises/25-web-certificate.md)

## Quick Start

```bash
make E=25 setup && make E=25 apply
```

## Configuration

**IMPORTANT:** Use staging for testing!

```hcl
use_production = false  # Avoid rate limits!
```

## Generated Files

```bash
ls -l gen/
# certificate.pem - Full chain
# private.pem - Private key
```

## Verification

```bash
openssl x509 -in gen/certificate.pem -text -noout | grep -A1 "Subject Alternative Name"
```

## Cleanup

```bash
make E=25 destroy
```
