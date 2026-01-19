# 24 - Creating a fixed number of servers

> **Working Code:** [`terraform/exercise-24-multi-server/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-24-multi-server/)

Write a Terraform configuration for deploying a configurable number of servers being defined by the following `config.auto.tfvars`:

```hcl
dnsZone        = "gxy.sdi.hdm-stuttgart.cloud"
serverBaseName = "work"
serverCount    = 2
```

`terraform apply` shall create the following:

1.  Two DNS entries:
    - `work-1.gxy.sdi.hdm-stuttgart.cloud`
    - `work-2.gxy.sdi.hdm-stuttgart.cloud`
2.  Two corresponding servers each endowed with its own unique ssh host key pair.
3.  Two corresponding sub directories `work-1` and `work-2` each containing its own `bin/ssh` and related `gen/known_hosts` file.
