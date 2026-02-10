# 19 - Partitions and Mounting (Manual)

> **Working Code:** [`terraform/exercise-19-volume-manual/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-19-volume-manual/)

**The Problem:** Servers are ephemeral. If you delete the server, the data on its local disk is gone.

**The Solution:** Use an external **Volume** (Block Storage). It survives server deletion and can be re-attached to a new server.

## Objective
Attach a 10GB volume to a server, then manually partition, format, and mount it.

## How-to

### 1. Terraform: Create & Attach
Define the volume and attach it to your server:

```hcl
resource "hcloud_volume" "web_data" {
  name      = "web-data"
  size      = 10
  location  = "hel1"
}

resource "hcloud_volume_attachment" "main" {
  volume_id = hcloud_volume.web_data.id
  server_id = hcloud_server.web.id
  automount = false  # We want to do it manually!
}
```

### 2. Manual Setup (SSH)
After `terraform apply`, SSH into the server to set up the disk.

**Find the disk:**
```bash
lsblk
# You'll likely see /dev/sdb of size 10G
```

**Partition it (fdisk):**
```bash
fdisk /dev/sdb
# Type 'n' (new), 'p' (primary), '1', enter, enter.
# Type 'w' (write).
```

**Format it (ext4):**
```bash
mkfs.ext4 /dev/sdb1
```

**Mount it:**
```bash
mkdir /mnt/data
mount /dev/sdb1 /mnt/data
```

### 3. Verification
Write a file:
```bash
echo "Important Data" > /mnt/data/file.txt
```

Now, if you destroy the server but keep the volume, your "Important Data" is safe.

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md) - Automating this entire process with Cloud-Init
