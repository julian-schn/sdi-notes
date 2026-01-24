# 27 - Combining Certificate Generation and Server Creation

> **Working Code:** [`terraform/exercise-27-combined-certificate/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-27-combined-certificate/)

## Overview
Combine certificate generation and server creation into one Terraform configuration for a fully automated HTTPS-enabled web server deployment.

## Prerequisites
- Completed [Exercise 25 - Web Certificate](./25-web-certificate.md)
- Completed [Exercise 26 - Testing Certificate](./26-testing-certificate.md)
- Understanding of Terraform dependencies and ordering

## Objective
Combine the certificate generation from Exercise 25 and the server creation/configuration from Exercise 26 into one cohesive Terraform configuration.

## Implementation

### Integration Strategy
Merge the two separate Terraform configurations into a single project that:

1. Generates the wildcard certificate using ACME provider
2. Creates the server with cloud-init
3. Creates DNS records for the server
4. Deploys the certificate to the server (via cloud-init write_files or provisioner)
5. Configures Nginx to use the certificate

### Key Considerations
- Ensure proper dependency ordering (certificate must be generated before server can use it)
- Use Terraform's `depends_on` where necessary
- Consider using cloud-init `write_files` to deploy certificates
- Ensure firewall allows both HTTP (80) and HTTPS (443)

### Resource Dependencies
The typical dependency chain:
1. ACME certificate generation
2. Server creation with cloud-init
3. DNS record creation
4. Certificate deployment to server
5. Nginx configuration and restart

## Verification
1. Initialize: `terraform init`
2. Plan to review resources: `terraform plan`
3. Apply configuration: `terraform apply`
4. Wait for cloud-init completion
5. Verify DNS resolution works
6. Test HTTP access: `curl http://g3.sdi.hdm-stuttgart.cloud`
7. Test HTTPS access: `curl https://g3.sdi.hdm-stuttgart.cloud`
8. Verify certificate in browser
9. Test all configured domains (apex and subdomains)

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [25 - Web Certificate](./25-web-certificate.md) - Certificate generation component
- [26 - Testing Certificate](./26-testing-certificate.md) - Server configuration component
- [15 - Cloud Init](./15-cloud-init.md) - Advanced cloud-init usage
