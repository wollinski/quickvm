#cloud-config
mounts:
  - [ shared_dir, /mnt, virtiofs, rw ]
users:
  - name: developer
    shell: /bin/bash
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $SSH_PUBKEY
