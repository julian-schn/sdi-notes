# Introduction to Infrastructure as Code

**The Problem:** Managing servers by clicking through a web console (like
Hetzner or AWS) is slow, hard to repeat, and impossible to version control.
If a server dies, rebuilding it exactly as it was relies on human memory or
outdated wikis.

**The Solution:** Infrastructure as Code (IaC) lets you define your servers,
networks, and firewalls in plain text files. You execute a command, and the
tool builds exactly what you described.

## What is Terraform?

In this course, we use **Terraform**. It is a declarative IaC tool. This
means you tell it *what* you want (e.g., "I want a Linux server with this
SSH key"), not *how* to build it. Terraform figures out the API calls needed
to make reality match your code.

## Why it matters

1. **Automation:** Spin up whole environments in seconds.
2. **Consistency:** Avoid "snowflake" servers (unique servers that are
   impossible to recreate).
3. **Version Control:** Store your infrastructure in Git. See who changed
   what, when, and why.
4. **Disaster Recovery:** If a datacenter goes down, point your Terraform
   code to a new region and hit apply.

## Next Steps

Ready to get started? Head over to the
[Terraform Installation](./terraform-install.md) guide and then work your
way through the [Exercises](../exercises/index.md).
