# 10 - Index Based Search

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
`plocate` provides fast filename search by maintaining an index of all files on the system. Instead of traversing the entire filesystem, it queries a pre-built database for instant results.

## Prerequisites
- Debian/Ubuntu-based system with package manager access
- sudo privileges for installing packages and building index

## Objective
Install `plocate`, run `updatedb` once, then use `locate <pattern>` for instant filename search; rerun `updatedb` after file changes.

## Implementation

### Step 1: Install plocate
Install the plocate package:

```bash
sudo apt install plocate
```

### Step 2: Build the Index
Build the initial file index:

```bash
sudo updatedb
```

This creates a database at `/var/lib/plocate/plocate.db` containing information about all files on the system.

### Step 3: Search for Files
Search for files using the locate command:

```bash
locate aptitude
```

This will instantly return all files and directories matching the pattern "aptitude".

### Step 4: Update Index After Changes
After adding new files or deleting existing ones, update the index:

```bash
sudo updatedb
```

::: tip Automatic Updates
Most systems have a daily cron job that automatically runs `updatedb`, so manual updates are typically only needed when immediate search results are required.
:::

## Verification
1. Install plocate: `sudo apt install plocate`
2. Build index: `sudo updatedb`
3. Search for a known file: `locate bash`
4. Create a test file: `touch ~/test-locate-file.txt`
5. Update index: `sudo updatedb`
6. Verify new file is searchable: `locate test-locate-file`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [11 - Tail](./11-tail.md) - Real-time file monitoring
- [12 - Journalctl](./12-journalctl.md) - System log search and monitoring
