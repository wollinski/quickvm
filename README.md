# IDEA
use libvirt to create a (disposable) VM with the following features:
- easy configuration which directories are mounted inside VM
  - e.g. dir from which VM was created. this can be used to compile and run a repo that was checked out in its own VM
- easy ssh access
  - e.g. directly drop into shell when VM is created or easy access via helper that also colors the terminal so that it is clear one is in VM

# Installation

ToDo:
- install script in $PATH
- cache cloud image on disk?
  - should we use minimal cloud images?
    - https://cloud-images.ubuntu.com/minimal/releases/

## install image signing key
To validate ubuntu images after download a signing key is installed as follows:
```bash
sudo make keyring
```
This installs `ubuntu-signingkey.asc` under `/usr/local/share/quickvm/ubuntu-signingkey.gpg`
The key has the following fingerprint:
```bash
$ gpg --keyring /usr/local/share/quickvm/ubuntu-signingkey.gpg --list-keys --with-fingerprint
/usr/local/share/quickvm/ubuntu-signingkey.gpg
----------------------------------------------
pub   rsa4096 2009-09-15 [SC]
      D2EB 4462 6FDD C30B 513D  5BB7 1A5D 6C4C 7DB8 7C81
uid           [ unknown] UEC Image Automatic Signing Key <cdimage@ubuntu.com>
```
Information about GPG keys used by Ubuntu is here: https://wiki.ubuntu.com/SecurityTeam/FAQ#GPG_Keys_used_by_Ubuntu

## cloudinit templates
When creating a new VM it is initially configured using _cloudinit_. The relevant files are created from templates that are stored under `${HOME}/.config/quickvm` by default:
```bash
$ cd ${HOME}/.config/quickvm; tree
.
└── templates
    └── cloudinit
        ├── meta-data.tpl
        └── user-data.tpl
```
When initially setting up `quickvm` the above file structure can be created as follows:
```bash
make templates
```

# ToDo

## resize disk
Example as starting point for automation
1. shutdown VM (or do this before initial start)
2. `qemu-img resize ubuntu.img +10G`
3. start VM
4. `sudo growpart /dev/vda 1 # resizes partition /dev/vda1`
5. `sudo resize2fs /dev/vda1`

# Links
https://www.surlyjake.com/blog/2020/10/09/ubuntu-cloud-images-in-libvirt-and-virt-manager/