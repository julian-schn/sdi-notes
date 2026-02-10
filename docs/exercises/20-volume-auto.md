# 20 - Volume Auto-Mounting

> **Working Code:** [`terraform/exercise-20-volume-auto/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-20-volume-auto/)

**The Problem:** Exercise 19 requires manual partitioning and mounting. Let's automate it.

**The Solution:** Use cloud-init to format and mount the volume automatically.

## Prerequisites
- [Exercise 19 - Volume Manual](./19-volume-manual.md)

## Objective
Automatically format and mount volume to `/volume01` using cloud-init.

## How-to

### 1. Disable Automount
```hcl
resource "hcloud_volume_attachment" "main_attachment" {
  automount = false  # Let cloud-init handle it
}
```

Pass device path to cloud-init:
```hcl
user_data = templatefile("cloud-init.yaml", {
  volume_device = hcloud_volume.data_volume.linux_device
})
```

### 2. Cloud-init Configuration
```yaml
disk_setup:
  ${volume_device}:
    table_type: gpt
    layout: true

fs_setup:
  - label: volume01
    filesystem: ext4
    device: ${volume_device}

mounts:
  - [ ${volume_device}, /volume01, "ext4", "defaults", "0", "0" ]
```

## Verification
```bash
terraform apply
./bin/ssh
df -h /volume01  # Should show /dev/sdb mounted
cat /etc/fstab   # Should have /volume01 entry
```

## Related Exercises
- [19 - Volume Manual](./19-volume-manual.md)
- [15 - Cloud Init](./15-cloud-init.md)
