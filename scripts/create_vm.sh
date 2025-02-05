#!/bin/bash
set -ue

# ToDo: All variables should be namespaced.

# ToDo: Is WORKDIR really necessary?
: "${WORKDIR:="$(pwd)"}"
: "${CONFIGDIR:=".isolation"}"

# ToDo: Installation or something that populates this.
: "${TEMPLATES:="${HOME}/.config/isolated-dev/templates"}"

: "${DISKIMAGE_DOWNLOAD:="https://cloud-images.ubuntu.com/noble/20250122/noble-server-cloudimg-amd64.img"}"
: "${DISKIMAGE_SHA256SUM:="482244b83f49a97ee61fb9b8520d6e8b9c2e3c28648de461ba7e17681ddbd1c9"}"
: "${DISKIMAGE:="${CONFIGDIR}/ubuntu.img"}"

: "${VMNAME:="isolationvm_$(basename "$WORKDIR")"}"
: "${CLOUDINIT_DATA:="${CONFIGDIR}/cloudinit"}"

: "${SSH_DIR:="${CONFIGDIR}/.ssh"}"



initDirectory() {
    [ -d "$CONFIGDIR" ] || (echo "init config dir" >&2 && mkdir "$CONFIGDIR")
    [ -f "$DISKIMAGE" ] || downloadImage
}

initCloudInit() {
    [ -d "$CLOUDINIT_DATA" ] || (echo "create cloudinit dir" >&2 && mkdir -p "$CLOUDINIT_DATA")
    [ -d "$SSH_DIR" ] || (echo "create ssh dir" >&2 && mkdir -p "$SSH_DIR")

    # ToDo: It should be checked whether VM was already created before doing this.
    # If there is a pub key in cloud init that was already deployed to VM it must be checked that the required privkey is avail.
    # For now only check that there is no priv key file yet
    [ -f "${SSH_DIR}/${VMNAME}" ] || ssh-keygen -t ed25519 -f "${WORKDIR}/${SSH_DIR}/${VMNAME}" -P ""

    [ -f "${CLOUDINIT_DATA}/user-data" ] || SSH_PUBKEY="$(cat "${SSH_DIR}/${VMNAME}.pub")" envsubst < "${TEMPLATES}/cloudinit/user-data.tpl" > "${CLOUDINIT_DATA}/user-data"
    # ToDo: Use meta-data to set hostname for DNS
    [ -f "${CLOUDINIT_DATA}/meta-data" ] || touch "${CLOUDINIT_DATA}/meta-data"
}

downloadImage() {
    echo "downloading disk image from $DISKIMAGE_DOWNLOAD" >&2 && wget "$DISKIMAGE_DOWNLOAD" -O $DISKIMAGE
    sha256sum -c <(echo "${DISKIMAGE_SHA256SUM} ${DISKIMAGE}") || (echo "verifying image hash failed" && exit 74)
}

createVM() {
    virt-install \
        --name "$VMNAME" \
        --memory 4096 \
        --vcpus 4 \
        --os-variant ubuntu22.04 \
        --nographics \
        --noautoconsole \
        --disk path="$DISKIMAGE" \
        --import \
        --filesystem type=mount,mode=passthrough,source="$WORKDIR",target="shared_dir",driver.type=virtiofs,driver.queue=1024 \
        --memorybacking source.type=memfd,access.mode=shared \
        --cloud-init user-data="${CLOUDINIT_DATA}/user-data",meta-data="${CLOUDINIT_DATA}/meta-data"
}

initVM() {
    # ToDo: Is there a better way to identify VM and perform checks?
    grep "^${VMNAME}$" <(virsh list --all --name) || createVM
    grep "^${VMNAME}$" <(virsh list --state-running --name) || virsh start "${VMNAME}"
}

# main
initDirectory
initCloudInit
initVM

#virsh --connect qemu:///system console "${VMNAME}"