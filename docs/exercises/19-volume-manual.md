# 19 - Volumes (Hetzner Auto-Format)

> **Working Code:** [`terraform/exercise-19-volume-manual/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-19-volume-manual/)

**The Problem:** Server local disks are ephemeral. Delete the server, lose the data.

**The Solution:** Use external Volume (block storage) that survives server deletion.

## Objective
Attach a 10GB volume using Hetzner's auto-format and auto-mount features.

## How-to

### 1. Create & Attach Volume
Hetzner can format and mount the volume automatically:

```hcl
resource "hcloud_volume" "data_volume" {
  name     = "data-volume"
  size     = 10
  location = "hel1"
  format   = "ext4"  # Hetzner formats it for you
}

resource "hcloud_volume_attachment" "main_attachment" {
  volume_id = hcloud_volume.data_volume.id
  server_id = hcloud_server.web.id
  automount = true  # Hetzner mounts it automatically
}
```

### 2. Verify
After `terraform apply`, SSH into the server:

```bash
lsblk  # See the volume (usually /dev/sdb)
df -h  # Volume is already mounted (typically at /mnt/HC_Volume_*)
```

Hetzner automatically formats and mounts the volume, saving you manual steps.

### 3. Test Persistence
```bash
echo "Important Data" > /mnt/HC_Volume_*/file.txt
# Destroy server but keep volume → data survives!
```

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md) - Full control with cloud-init
