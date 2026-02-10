# 12 - Journalctl

> **Note:** Just a command-line exercise.

**The Problem:** Modern Linux systems (systemd) store logs in a binary format, so you can't just `cat` text files in `/var/log` anymore for many services.

**The Solution:** `journalctl` is the universal query tool for systemd logs.

## Objective
Query system logs effectively.

## How-to

### 1. View Everything (Paged)
```bash
journalctl
```
Use regular `less` controls (arrows, `q` to quit).

### 2. Follow Live Logs (Like tail -f)
```bash
journalctl -f
```

### 3. Filter by Service (The Most Useful Command)
See only logs for a specific service (e.g., nginx or ssh):
```bash
journalctl -u nginx
journalctl -u ssh -f  # Follow live!
```

### 4. Filter by Time or Boot
```bash
journalctl -b          # Logs from current boot only
journalctl --since "1 hour ago"
journalctl -p err      # Errors only
```

## Related Exercises
- [11 - Tail](./11-tail.md) - The old-school file way
