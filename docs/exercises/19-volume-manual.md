# 19 - Partitions and Mounting

> **Working Code:** [`terraform/exercise-19-volume-manual/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-19-volume-manual/)

## Overview
Attach a volume to a server and manually partition/mount it. This exercise demonstrates fundamental Linux disk management including partitioning, filesystem creation, and persistent mounting.

## Prerequisites
- Completed [Exercise 15 - Cloud Init](./15-cloud-init.md) or similar
- Understanding of Linux filesystem concepts
- Familiarity with fdisk and mount commands

## Objective
Attach a Hetzner Cloud volume, manually create partitions using fdisk, format them with different filesystems (ext4, xfs), mount them, and configure persistent mounting via /etc/fstab.

## Implementation

### Step 1: Terraform Configuration
Add volume and attachment resources:

```hcl
resource "hcloud_volume" "data_volume" {
  name      = "${var.project}-volume"
  size      = 10
  location  = var.location
}

resource "hcloud_volume_attachment" "main_attachment" {
  volume_id = hcloud_volume.data_volume.id
  server_id = hcloud_server.main_server.id
  automount = true
}
```

### Step 2: Apply Terraform
Create the infrastructure:

```bash
terraform apply
```

### Step 3: SSH into the Server
Connect to the server:

```bash
./bin/ssh
```

### Step 4: Identify the Volume
Check the current mounts:

```bash
df -h
# Look for /mnt/HC_Volume_...
```

### Step 5: Unmount and Partition
Unmount the volume and create partitions:

```bash
# Unmount
umount /mnt/HC_Volume_...

# Partition (interactive)
fdisk /dev/sdb
# n (new), p (primary), 1, default, +5G
# n (new), p (primary), 2, default, default
# w (write)
```

### Step 6: Format Partitions
Create filesystems on the partitions:

```bash
mkfs -t ext4 /dev/sdb1
mkfs -t xfs /dev/sdb2
```

### Step 7: Mount Partitions
Create mount points and mount the partitions:

```bash
mkdir /disk1 /disk2
mount /dev/sdb1 /disk1
mount /dev/sdb2 /disk2
```

### Step 8: Make Persistent with fstab
Configure automatic mounting on boot:

```bash
# Get UUIDs
blkid

# Edit /etc/fstab
echo "/dev/sdb1 /disk1 ext4 defaults 0 0" >> /etc/fstab
echo "UUID=... /disk2 xfs defaults 0 0" >> /etc/fstab

# Test
mount -a
```

### Step 9: Reboot and Verify
Reboot to verify persistence:

```bash
reboot
# Wait...
ssh ...
df -h
```

## Verification
1. Apply Terraform: `terraform apply`
2. SSH into server: `./bin/ssh`
3. Verify volume attached: `lsblk`
4. Complete partitioning and formatting steps
5. Check mounts: `df -h | grep disk`
6. Verify fstab: `cat /etc/fstab`
7. Reboot and verify mounts persist: `sudo reboot` then check `df -h`

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [20 - Volume Auto](./20-volume-auto.md) - Automating volume setup with cloud-init
