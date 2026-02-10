# 6 - SSH Agent Forwarding

> **Note:** Just a command-line exercise. No terraform needed.

**The Problem:** You need to SSH into a target server (System B) that is only accessible from a bastion host (System A), but copying your private keys to the bastion is unsafe.

**The Solution:** SSH Agent Forwarding (`-A`) lets the bastion securely "borrow" your local key for the next hop.

## Prerequisites
- SSH access to intermediate (bastion) host
- SSH access to target host from bastion

## Objective
Use `ssh -A bastion` then `ssh target` so your local agent signs auth requests on the final host without copying keys anywhere.

## How-to

### 1. Connect with Forwarding
Connect to the bastion with forwarding enabled:

```bash
ssh -A bastion
```

### 2. Jump to Target
From the bastion, jump to the target:

```bash
ssh target
```

Auth happens via your local agent. No keys stored on the bastion.

## Related Exercises
- [16 - SSH Known Hosts](./16-ssh-known-hosts.md) - Managing SSH host keys for automated connections
