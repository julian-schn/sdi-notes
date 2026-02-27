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

### 4. Identify the Volume

```bash
lsblk
```

The Hetzner volume is the 10G disk — **the device name (`sda` or `sdb`) can change between reboots and even from what Terraform's output shows.** Always identify it by size via `lsblk`, not by assuming a fixed name.

### 5. Wipe and Partition

```bash
sudo wipefs -a /dev/<device>

sudo fdisk /dev/<device>
```

Inside fdisk:
```
g        ← new GPT partition table
n        ← new partition
1        ← partition number
Enter    ← accept default first sector
+5G      ← last sector
n        ← new partition
2        ← partition number
Enter    ← accept default first sector
Enter    ← accept default last sector (remaining space)
w        ← write and exit
```

### 6. Format Partitions

```bash
sudo mkfs -t ext4 /dev/<device>1
sudo mkfs -t xfs  /dev/<device>2
```

### 7. Mount Partitions

```bash
sudo mkdir /disk1 /disk2
sudo mount /dev/<device>1 /disk1
sudo mount /dev/<device>2 /disk2
df -h | grep disk
```

### 8. Make Persistent with fstab

Always use UUIDs — device names change across reboots, UUIDs don't.

```bash
sudo blkid /dev/<device>1 /dev/<device>2

echo "UUID=<uuid1> /disk1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=<uuid2> /disk2 xfs  defaults 0 0" | sudo tee -a /etc/fstab

sudo mount -a    # test — should produce no errors
```

### 9. Reboot and Verify

```bash
sudo reboot
# reconnect with ./bin/ssh
df -h | grep disk    # both /disk1 and /disk2 should still be mounted
```

## Problems & Learnings

::: warning Common Issues
- **Device name changes between reboots** — the volume may be `sda` or `sdb` depending on boot order. Always use `lsblk` to identify it by size, and use UUIDs in `/etc/fstab` (never `/dev/sdX`)
- **`automount = true` pre-creates a partition** — if the Terraform config uses `automount = true`, Hetzner will format the disk as a single partition before you log in. Use `sudo wipefs -a /dev/<device>` to clear it before running `fdisk`
- **fdisk `+5G` goes on the Last sector prompt, not First sector** — press Enter to accept the default first sector, then type `+5G`
:::

::: tip Key Takeaways
- Use UUIDs in `/etc/fstab` for reliable persistent mounts regardless of device naming
- `lsblk` is the right tool to identify disks; `blkid` gives you the UUIDs
- `sudo mount -a` tests your fstab before rebooting — a typo here can make the server unbootable
:::

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md) - Full control with cloud-init
