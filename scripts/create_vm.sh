#!/bin/bash

WORKDIR="$(pwd)"

# ToDo: Create config dir dynamically with some init method
CONFIGDIR=".isolation"

# ToDo: This should not be in every CONFIGDIR but in a central place or downloaded
DISKIMAGE="${CONFIGDIR}/ubuntu.img"
CLOUDINIT_DATA="${CONFIGDIR}/cloudinit"

# Create name dynamically so that it contains directory where script is invoked
VMNAME="isolationvm_$(basename "$WORKDIR")"

virt-install \
    --name "$VMNAME" \
    --memory 4096 \
    --vcpus 4 \
    --os-variant ubuntu22.04 \
    --nographics \
    --disk path="$DISKIMAGE" \
    --import \
    --filesystem type=mount,mode=passthrough,source="$WORKDIR",target="shared_dir",driver.type=virtiofs,driver.queue=1024 \
    --memorybacking source.type=memfd,access.mode=shared \
    --cloud-init user-data="${CLOUDINIT_DATA}/user-data",meta-data="${CLOUDINIT_DATA}/meta-data"