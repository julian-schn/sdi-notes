# 20 - Volume Auto-Mounting

> **Working Code:** [`terraform/exercise-20-volume-auto/`](https://github.com/julian-schn/sdi-notes/tree/main/terraform/exercise-20-volume-auto/)

## Overview
Automatically format and mount a volume to `/volume01` using Cloud-init. This eliminates the manual steps from Exercise 19 and provides a fully automated, repeatable volume setup process.

## Prerequisites
- Completed [Exercise 19 - Volume Manual](./19-volume-manual.md)
- Understanding of cloud-init disk_setup and fs_setup modules
- Familiarity with [Exercise 15 - Cloud Init](./15-cloud-init.md)

## Objective
Automatically format and mount the volume to `/volume01` using Cloud-init.

## Implementation

### Step 1: Terraform Configuration
Disable automount so cloud-init can handle it:

```hcl
resource "hcloud_volume" "data_volume" {
  # ...
}

resource "hcloud_volume_attachment" "main_attachment" {
  # ...
  automount = false
}
```

Pass the device path to Cloud-init:

```hcl
user_data = templatefile("${path.module}/cloud-init.yaml", {
  # ...
  volume_device = hcloud_volume.data_volume.linux_device
})
```

### Step 2: Cloud-init Configuration
Use `disk_setup`, `fs_setup`, and `mounts` modules in `cloud-init.yaml`:

```yaml
disk_setup:
  ${volume_device}:
    table_type: gpt
    layout: true
    overwrite: false

fs_setup:
  - label: volume01
    filesystem: ext4
    device: ${volume_device}

mounts:
  - [ ${volume_device}, /volume01, "ext4", "defaults", "0", "0" ]
```

## Verification

### Step 1: Apply Terraform
```bash
terraform apply
```

### Step 2: SSH into the Server
```bash
./bin/ssh
```

### Step 3: Check Mount
```bash
df -h /volume01
```

You should see:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb         10G   24K  9.8G   1% /volume01
```

### Step 4: Check Persistence
```bash
cat /etc/fstab
```

You should see an entry for `/volume01`.

## Problems & Learnings

::: warning Common Issues
*This section will be filled in collaboratively. Common issues encountered during this exercise will be documented here.*
:::

::: tip Key Takeaways
*Key learnings and best practices from this exercise will be documented here.*
:::

## Related Exercises
- [19 - Volume Manual](./19-volume-manual.md) - Manual volume setup process
- [15 - Cloud Init](./15-cloud-init.md) - Cloud-init fundamentals
