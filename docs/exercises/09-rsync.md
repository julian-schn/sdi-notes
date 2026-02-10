# 9 - Directory Transfer with Rsync

> **Note:** Just a command-line exercise. No terraform needed.

**The Problem:** `scp` copies blindly. If a transfer fails halfway, or you just changed one file in a specific directory, `scp` copies *everything* again. Slow and wasteful.

**The Solution:** `rsync` only copies the differences (deltas). It's faster, supports resuming, and preserves permissions/timestamps.

## Prerequisites
- `rsync` installed on both local and remote machines (`sudo apt install rsync`)

## Objective
Use `rsync` to efficiently sync directories over SSH.

## How-to

### 1. Basic Sync
Copy local directory to remote:

```bash
rsync -avz -e ssh ./local_dir/ user@remote:~/backup/
```

**The Flags:**
- `-a`: Archive mode (preserves permissions, times, owners - indispensable)
- `-v`: Verbose (tell me what you're doing)
- `-z`: Compress (save bandwidth)
- `-e ssh`: Use SSH as the transport

### 2. Sync Back (Restore)
To pull files back (remote to local), just flip the arguments:

```bash
rsync -avz -e ssh user@remote:~/backup/ ./local_restore/
```

::: tip Trailing Slashes Matter!
- `src/` (with slash) = copy the **contents** of src.
- `src` (no slash) = copy the **directory itself** (creating `dest/src`).
:::

## Related Exercises
- [6 - SSH Agent Forwarding](./06-ssh-hopping.md) - Auth basics
