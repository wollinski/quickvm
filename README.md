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