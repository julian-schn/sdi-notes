# Exercise 26 - Testing Certificate

> **Full Guide:** [docs/exercises/26-testing-certificate.md](../../docs/exercises/26-testing-certificate.md)

## Quick Start

```bash
make E=26 setup && make E=26 apply
```

## Configuration

```hcl
use_production = false  # Test with staging first!
project = "g2"
dns_zone = "g2.sdi.hdm-stuttgart.cloud"
```

## Known Issue: DNS Cleanup

If switching from Exercise 22/23, clean DNS records:

```bash
source terraform/.env
echo "server ns1.sdi.hdm-stuttgart.cloud
update delete www.g2.sdi.hdm-stuttgart.cloud. CNAME
update delete www.g2.sdi.hdm-stuttgart.cloud. A
send" | nsupdate -y "hmac-sha512:g2.key:$TF_VAR_dns_secret"
```

## Verification

```bash
# HTTPS access (browser warning expected with staging cert)
# https://g2.sdi.hdm-stuttgart.cloud
# https://www.g2.sdi.hdm-stuttgart.cloud

./bin/ssh
```

## Cleanup

```bash
make E=26 destroy
```
