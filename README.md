# IDEA
use libvirt to create a (disposable) VM with the following features:
- easy configuration which directories are mounted inside VM
  - e.g. dir from which VM was created. this can be used to compile and run a repo that was checked out in its own VM
- easy ssh access
  - e.g. directly drop into shell when VM is created or easy access via helper that also colors the terminal so that it is clear one is in VM

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