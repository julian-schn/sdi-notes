# 26 - Testing Your Certificate

> **Working Code:** [`terraform/exercise-26-testing-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-26-testing-certificate/)

**The Problem:** You have certificate files from Exercise 25, but the server uses self-signed (snakeoil) cert.

**The Solution:** Copy certs to server and configure Nginx.

## Objective
Create server responding to `https://www.g2...` with valid Let's Encrypt certificate.

## How-to

### 1. Variables
```hcl
variable "dns_zone" {
  default = "g2.sdi.hdm-stuttgart.cloud"
}
```

This should create DNS entries:
1. `g2.sdi.hdm-stuttgart.cloud`
2. `www.g2.sdi.hdm-stuttgart.cloud`
3. `mail.g2.sdi.hdm-stuttgart.cloud`

### 2. Verify Nginx is Running
The Terraform config deploys Nginx and the certificate automatically via cloud-init. After `terraform apply` completes, verify Nginx is running:

```bash
systemctl status nginx
```

To test the configuration manually:

```bash
sudo /usr/sbin/nginx -t
```

::: tip nginx not in PATH
`nginx` is installed at `/usr/sbin/nginx` but may not be in the devops user's PATH. Use the full path or `sudo nginx -t`.
:::

### 3. Test with Staging Certificate
Your current staging certificate will cause warnings. Point your browser to:
- `https://g2.sdi.hdm-stuttgart.cloud`
- `https://www.g2.sdi.hdm-stuttgart.cloud`
- `https://mail.g2.sdi.hdm-stuttgart.cloud`

Overrule certificate related warnings to actually see the pages. Inspect the certificate. You should find `g2.sdi.hdm-stuttgart.cloud` and `*.g2.sdi.hdm-stuttgart.cloud`.

### 4. Production Certificate
If your certificate is basically correct, re-generate it using the production setting `https://acme-v02.api.letsencrypt.org/directory` in [Exercise 25 - Web Certificate](./25-web-certificate.md).

::: danger Remember
**Don't forget reverting back to staging after completion.** You may regret it due to rate limits!
:::

Copy the generated certificate to your server again. This time your browser should present a flawless view with respect to the underlying certificate for all three URLs.

## Verification
1. Apply Terraform: `terraform apply`
2. Verify Nginx is running: `systemctl status nginx`
3. Test staging certificate in browser — expect warnings (staging cert)
4. Inspect certificate in browser — should show `g2.sdi.hdm-stuttgart.cloud` and `*.g2.sdi.hdm-stuttgart.cloud`
5. Generate production certificate in Exercise 25 (if staging works)
6. Re-apply to redeploy with production cert: `terraform apply`
7. Verify HTTPS works without warnings

## Problems & Learnings

::: warning Common Issues
- Browser warnings on staging certificates are expected — this is the intended behavior for testing.
- `nginx` is not in the devops user's PATH; use `sudo /usr/sbin/nginx -t` to test config.
:::

::: tip Key Takeaways
- The Terraform config deploys Nginx and the certificate fully automatically via cloud-init — no manual certificate copying needed.
- Always test with a staging certificate first before switching to production to avoid hitting Let's Encrypt rate limits.
:::

## Related Exercises
- [27 - Combined Setup](./27-combined-setup.md)
