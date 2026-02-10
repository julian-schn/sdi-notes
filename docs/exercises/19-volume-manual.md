# 19 - Volumes (Manual Setup)

> **Working Code:** [`terraform/exercise-19-volume-manual/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-19-volume-manual/)

**The Problem:** Server local disks are ephemeral. Delete the server, lose the data.

**The Solution:** Use external Volume (block storage) that survives server deletion.

## Objective
Attach 10GB volume and manually partition, format, and mount it.

## How-to

### 1. Create & Attach Volume
```hcl
resource "hcloud_volume" "web_data" {
  name     = "web-data"
  size     = 10
  location = "hel1"
}

resource "hcloud_volume_attachment" "main" {
  volume_id = hcloud_volume.web_data.id
  server_id = hcloud_server.web.id
  automount = false
}
```

### 2. Manual Setup (SSH)
After `terraform apply`, SSH into server:

```bash
# Find disk
lsblk  # Usually /dev/sdb

# Partition with fdisk
fdisk /dev/sdb
# n, p, 1, enter, enter, w

# Format
mkfs.ext4 /dev/sdb1

# Mount
mkdir /mnt/data
mount /dev/sdb1 /mnt/data
```

### 3. Test Persistence
```bash
echo "Important Data" > /mnt/data/file.txt
# Destroy server but keep volume → data survives!
```

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md)
