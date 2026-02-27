# 25 - Certificates as Code

> **Working Code:** [`terraform/exercise-25-web-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-25-web-certificate/)

**The Problem:** Certbot on the server works, but if the server dies, the cert's gone. Renewal automation is another moving part to break.

**The Solution:** Use Terraform's `acme` provider to generate certificates locally, then upload to any server.

## Objective
Generate a wildcard certificate (`*.g2.sdi.hdm-stuttgart.cloud`) using Terraform and ACME (Let's Encrypt).

## How-to

### 1. Configure ACME Provider

::: danger Rate Limits!
Use staging while developing. Production Let's Encrypt allows only 5 certs per week.
:::

```hcl
provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
```

### 2. Register Account
```hcl
resource "tls_private_key" "acme_registration" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.acme_registration.private_key_pem
  email_address   = var.email
}
```

### 3. Request Certificate (DNS-01 Challenge)
Terraform requests cert from Let's Encrypt, LE responds with DNS TXT challenge, Terraform creates the record using your DNS provider, LE verifies and issues cert, then Terraform cleans up.

```hcl
resource "acme_certificate" "wildcard" {
  account_key_pem          = acme_registration.registration.account_key_pem
  common_name              = var.dns_zone
  subject_alternative_names = ["*.${var.dns_zone}"]

  dns_challenge {
    provider = "rfc2136"
    config = {
      RFC2136_NAMESERVER = "ns1.sdi.hdm-stuttgart.cloud"
      RFC2136_TSIG_KEY   = "${var.project}.key"
      # ... TSIG config ...
    }
  }
}
```

### 4. Save Certificates
```hcl
resource "local_file" "fullchain" {
  content  = "${acme_certificate.wildcard.certificate_pem}${acme_certificate.wildcard.issuer_pem}"
  filename = "gen/fullchain.pem"
}

resource "local_file" "private_key" {
  content  = acme_certificate.wildcard.private_key_pem
  filename = "gen/private.pem"
}
```

## Verification
```bash
terraform apply  # Watch "Challenges" log
ls gen/          # See .pem files
openssl x509 -in gen/fullchain.pem -text -noout  # Issuer: "Fake LE"
```

## Problems & Learnings

::: warning Common Issues
- Always use the staging URL during development — production has strict rate limits that can lock you out for days.
- The wildcard (`*.g2.sdi.hdm-stuttgart.cloud`) and apex (`g2.sdi.hdm-stuttgart.cloud`) are separate SANs and must both be listed explicitly.
:::

::: tip Key Takeaways
- Only switch to the production ACME URL once staging succeeds, and revert immediately after.
- Verify the certificate with `openssl x509 -in gen/certificate.pem -text -noout | grep -A2 "Subject Alternative"` to confirm both SANs are present.
:::

## Related Exercises
- [26 - Testing Certificate](./26-testing-certificate.md)
