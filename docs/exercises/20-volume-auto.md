# 20 - Mount point's name specification

> **Working Code:** [`terraform/exercise-20-volume-auto/`](../../terraform/exercise-20-volume-auto/)

- Goal: Automatically format and mount the volume to `/volume01` using Cloud-init.

## Terraform Configuration

We disable automount so we can handle it ourselves:

```hcl
resource "hcloud_volume" "data_volume" {
  # ...
}

resource "hcloud_volume_attachment" "main_attachment" {
  # ...
  automount = false
}
```

We pass the device path to Cloud-init:

```hcl
user_data = templatefile("${path.module}/cloud-init.yaml", {
  # ...
  volume_device = hcloud_volume.data_volume.linux_device
})
```

## Cloud-init Configuration

We use `disk_setup`, `fs_setup`, and `mounts` modules:

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

1. **Apply Terraform**:
   ```bash
   terraform apply
   ```

2. **SSH into the server**:
   ```bash
   ./bin/ssh
   ```

3. **Check Mount**:
   ```bash
   df -h /volume01
   ```
   You should see:
   ```
   Filesystem      Size  Used Avail Use% Mounted on
   /dev/sdb         10G   24K  9.8G   1% /volume01
   ```

4. **Check Persistence**:
   ```bash
   cat /etc/fstab
   ```
   You should see an entry for `/volume01`.
