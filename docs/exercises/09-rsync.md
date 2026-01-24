# 9 - Directory Transfer with Rsync and SSH

> **Note:** This is a conceptual/command-line exercise. No terraform implementation required.

## Overview
With `rsync` you can synchronize directories between two machines. It only copies the differences (changed or new files), making it much faster than `scp`. When combined with SSH, it encrypts data in transit and uses SSH authentication.

## Prerequisites
- SSH access to remote host
- rsync installed on both local and remote machines

## Objective
Use `rsync -avz -e ssh src/ user@host:dest/` to copy only deltas over SSH; rerun the same command to sync changes both ways as needed.

## Implementation

### Step 1: Install rsync
Install rsync on both local and remote systems:

```bash
sudo apt install rsync
```

### Step 2: Initial Directory Copy
Copy a local directory to the remote host:

```bash
rsync -avz -e ssh ~/projects/localdir/ user@remotehost:~/backup/
```

Flags explained:
- `-a`: Archive mode (preserves permissions, timestamps, etc.)
- `-v`: Verbose output
- `-z`: Compress data during transfer
- `-e ssh`: Use SSH for transfer

### Step 3: Verify Incremental Sync
Run the same command again:

```bash
rsync -avz -e ssh ~/projects/localdir/ user@remotehost:~/backup/
```

rsync compares directories and syncs only changes. You should see minimal output:

```bash
sending incremental file list

sent 123 bytes  received 45 bytes  total size 0
```

### Step 4: Sync Remote Changes
Make changes on the remote host:
- SSH into remote host
- Add a new file to `/backup/localdir/`
- Log out

Run the rsync command again on your local machine. rsync will detect and sync the changes.

### Step 5: Reverse Direction Sync
To sync from remote to local, reverse the source and destination:

```bash
rsync -avz -e ssh user@remotehost:~/backup/dir/ ~/projects/dir/
```

## Verification
1. Create test files locally and sync to remote: `rsync -avz -e ssh ~/test/ user@host:~/test/`
2. Verify files exist on remote: `ssh user@host "ls -la ~/test/"`
3. Modify files on remote and sync back: `rsync -avz -e ssh user@host:~/test/ ~/test/`
4. Verify changes are reflected locally

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [6 - SSH Agent Forwarding](./06-ssh-hopping.md) - Using SSH for authentication
- [16 - SSH Known Hosts](./16-ssh-known-hosts.md) - Managing SSH host keys
