# 10 - Index Based Search

> **Note:** Just a command-line exercise.

**The Problem:** `find / -name "*foo*"` is slow because it crawls the entire disk every time.

**The Solution:** `plocate` (or `locate`) queries a pre-built database. It's instant.

## Prerequisites
- `plocate` installed (`sudo apt install plocate`)

## Objective
Install `plocate`, build the index, and search instantly.

## How-to

### 1. Build the Index
The index is usually built daily by a cron job, but run it manually now to populate it:

```bash
sudo updatedb
```

### 2. Search
Find files instantly:

```bash
locate aptitude
```

If you just created a file and `locate` can't find it, run `sudo updatedb` again.

## Related Exercises
- [11 - Tail](./11-tail.md) - Monitoring files
- [12 - Journalctl](./12-journalctl.md) - System logs
