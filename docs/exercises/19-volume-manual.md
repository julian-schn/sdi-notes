# 19 - Partitions and Mounting

> **Working Code:** [`terraform/exercise-19-volume-manual/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-19-volume-manual/)

- Goal: Attach a volume to a server and manually partition/mount it.

## Terraform Configuration

We add a volume and attach it:

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

## Manual Steps (The Exercise)

1. **Apply Terraform**:
   ```bash
   terraform apply
   ```

2. **SSH into the server**:
   ```bash
   ./bin/ssh
   ```

3. **Identify the volume**:
   ```bash
   df -h
   # Look for /mnt/HC_Volume_...
   ```

4. **Unmount and Partition**:
   ```bash
   # Unmount
   umount /mnt/HC_Volume_...
   
   # Partition (interactive)
   fdisk /dev/sdb
   # n (new), p (primary), 1, default, +5G
   # n (new), p (primary), 2, default, default
   # w (write)
   ```

5. **Format**:
   ```bash
   mkfs -t ext4 /dev/sdb1
   mkfs -t xfs /dev/sdb2
   ```

6. **Mount**:
   ```bash
   mkdir /disk1 /disk2
   mount /dev/sdb1 /disk1
   mount /dev/sdb2 /disk2
   ```

7. **Make Permanent (fstab)**:
   ```bash
   # Get UUIDs
   blkid
   
   # Edit /etc/fstab
   echo "/dev/sdb1 /disk1 ext4 defaults 0 0" >> /etc/fstab
   echo "UUID=... /disk2 xfs defaults 0 0" >> /etc/fstab
   
   # Test
   mount -a
   ```

8. **Reboot and Verify**:
   ```bash
   reboot
   # Wait...
   ssh ...
   df -h
   ```
