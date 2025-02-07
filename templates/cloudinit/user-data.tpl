#cloud-config
mounts:
  - [ shared_dir, /mnt, virtiofs, rw ]
ssh_keys:
  ed25519_private: host-privkey-here
  ed25519_public: host-pubkey-here
users:
  - name: developer
    shell: /bin/bash
    sudo:
      - ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - user-pubkey-here
