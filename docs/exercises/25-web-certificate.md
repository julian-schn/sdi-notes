# 25 - Creating a web certificate

> **Working Code:** [`terraform/exercise-25-web-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-25-web-certificate/)

> [!CAUTION]
> During configuration **always use the staging URL** `https://acme-staging-v02.api.letsencrypt.org/directory` rather than `https://acme-v02.api.letsencrypt.org/directory` for generating certificates. There are rate limits!

As an example we assume your group has write privileges to a zone `g3.sdi.hdm-stuttgart.cloud`. Follow the `acme_certificate` documentation using "rfc2136 provider configuration" as your DNS provider creating a wildcard certificate for:

1.  The zone apex e.g., `g3.sdi.hdm-stuttgart.cloud`.
2.  A wildcard certificate `*.g3.sdi.hdm-stuttgart.cloud` covering arbitrary hosts in this zone like e.g.:
    - `www.g3.sdi.hdm-stuttgart.cloud`
    - `mail.g3.sdi.hdm-stuttgart.cloud`

The `subject_alternative_names` attribute is your friend. The subsequent web server certificate installation requires two files:

1.  Private key file e.g. `private.pem`.
2.  Wildcard certificate key file e.g. `certificate.pem`.

Use resource `local_file` for generating this key pair in a sub folder `gen` of your current project.

> [!CAUTION]
> Due to a DNS provider related issue you must use at least acme provider version `v2.23.2`. You are best off not specifying any version at all receiving the latest release automatically:

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
