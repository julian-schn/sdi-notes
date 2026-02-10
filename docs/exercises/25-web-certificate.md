# 25 - Certificates as Code

> **Working Code:** [`terraform/exercise-25-web-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-25-web-certificate/)

**The Problem:** Running Certbot on the server (Exercise 21) works, but the certificate lives *on the server*. If the server dies, the cert is gone. Also, automating the renewal logic inside the server is just another moving part to break.

**The Solution:** Use the Terraform `acme` provider to request the certificate **locally** on your machine (or CI runner) and store it. Then, upload it to any server that needs it.

## Objective
Generate a **wildcard certificate** (`*.g3.sdi.hdm-stuttgart.cloud`) using Terraform and the ACME (Let's Encrypt) provider.

## How-to

### 1. The ACME Provider
This provider talks to Let's Encrypt for you.

::: danger Use Staging!
Always use the `acme-staging` URL while developing. Production Let's Encrypt has strict rate limits (5 per week!).
:::

```hcl
provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
```

### 2. Register Account
You need an account key (just like when running certbot manually):

```hcl
resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = "devops@example.com"
}
```

### 3. Request Certificate (DNS Challenge)
This is the magic part. Terraform will:
1. Ask Let's Encrypt for a cert.
2. LE will say "Prove you own this domain by setting a DNS TXT record".
3. Terraform will **automatically create that DNS record** using your DNS provider config.
4. LE creates the cert.
5. Terraform cleans up the DNS record.

```hcl
resource "acme_certificate" "cert" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = "*.g3.sdi.hdm-stuttgart.cloud"
  
  dns_challenge {
    provider = "rfc2136" # Generic DNS update (TSIG)
    config = {
      RFC2136_NAMESERVER = "ns1.sdi.hdm-stuttgart.cloud"
      # ... keys ...
    }
  }
}
```

### 4. Save to Disk
Save the resulting files so you can inspect them:

```hcl
resource "local_file" "cert" {
  content  = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
  filename = "gen/fullchain.pem"
}

resource "local_file" "key" {
  content  = acme_certificate.certificate.private_key_pem
  filename = "gen/privkey.pem"
}
```

## Verification
1. `terraform apply` -> Watch the "Challenges" log messages.
2. `ls gen/` -> You should see your `.pem` files.
3. `openssl x509 -in gen/fullchain.pem -text -noout` -> Check the details (Issuer should be "Fake LE").

## Related Exercises
- [26 - Testing Certificate](./26-testing-certificate.md) - Actually using these files on a server
