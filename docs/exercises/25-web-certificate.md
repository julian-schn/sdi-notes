# 25 - Creating a Web Certificate

> **Working Code:** [`terraform/exercise-25-web-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-25-web-certificate/)

## Overview
Use Terraform to generate wildcard certificates from Let's Encrypt via the ACME provider, supporting both the zone apex and wildcard subdomains.

## Prerequisites
- Access to DNS zone with dynamic update capability
- Understanding of ACME DNS-01 challenge
- Familiarity with TLS certificate concepts

## Objective
Generate a wildcard certificate for your DNS zone using the ACME provider with DNS-01 challenge (RFC2136).

::: danger Rate Limits
During configuration **always use the staging URL** `https://acme-staging-v02.api.letsencrypt.org/directory` rather than `https://acme-v02.api.letsencrypt.org/directory` for generating certificates. There are rate limits!
:::

## Implementation

### Step 1: Provider Configuration
Configure the ACME provider with required version:

::: danger Version Requirement
Due to a DNS provider related issue you must use at least acme provider version `v2.23.2`. You are best off not specifying any version at all receiving the latest release automatically:
:::

```hcl
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    acme = {
      source  = "vancluever/acme"
    }
  }
  required_version = ">= 0.13"
}
```

### Step 2: Certificate Configuration
Create a wildcard certificate covering:
1. The zone apex e.g., `g3.sdi.hdm-stuttgart.cloud`
2. A wildcard certificate `*.g3.sdi.hdm-stuttgart.cloud` covering arbitrary hosts like:
   - `www.g3.sdi.hdm-stuttgart.cloud`
   - `mail.g3.sdi.hdm-stuttgart.cloud`

Use the `subject_alternative_names` attribute for multiple domains.

### Step 3: Export Certificate Files
The subsequent web server certificate installation requires two files:
1. Private key file e.g. `private.pem`
2. Wildcard certificate key file e.g. `certificate.pem`

Use resource `local_file` for generating this key pair in a sub folder `gen` of your current project.

### Example Configuration Pattern
Follow the `acme_certificate` documentation using "rfc2136 provider configuration" as your DNS provider.

## Verification
1. Initialize Terraform: `terraform init`
2. Apply with staging URL: `terraform apply`
3. Verify certificate files created:
   ```bash
   ls -la gen/private.pem gen/certificate.pem
   ```
4. Inspect certificate:
   ```bash
   openssl x509 -in gen/certificate.pem -text -noout
   ```
5. Verify subject alternative names include both apex and wildcard

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [26 - Testing Certificate](./26-testing-certificate.md) - Installing and testing the certificate
- [27 - Combined Setup](./27-combined-setup.md) - Integrating certificate with server creation
