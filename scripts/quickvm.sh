#!/bin/bash
set -ue

# ToDo: All variables should be namespaced.

# ToDo: This must be manually synced with the corresponding path in Makefile. Should rather be defined in one single place.
: "${QUICKVM_LIBS:="/usr/local/lib/quickvm"}"

# ToDo: Is WORKDIR really necessary?
: "${WORKDIR:="$(pwd)"}"
: "${CONFIGDIR:=".isolation"}"

# ToDo: Installation or something that populates this.
: "${TEMPLATES:="${HOME}/.config/quickvm/templates"}"

: "${DISKIMAGE:="${CONFIGDIR}/ubuntu.img"}"
# ToDo: This must be manually synced with the corresponding path in Makefile. Can this be improved?
: "${DISKIMAGE_SIGNINGKEY:="/usr/local/share/quickvm/ubuntu-signingkey.gpg"}"
: "${DISKIMAGE_DOWNLOAD:="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"}"
: "${DISKIMAGE_CHECKSUM_URI:="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"}"
: "${DISKIMAGE_CHECKSUM_SIG_URI="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS.gpg"}"

: "${VMNAME:="isolationvm_$(basename "$WORKDIR")"}"
: "${CLOUDINIT_DATA:="${CONFIGDIR}/cloudinit"}"

: "${SSH_DIR:="${CONFIGDIR}/.ssh"}"
: "${CONNECTION_DELAY_SECONDS:="5"}"


source "${QUICKVM_LIBS}/validateImage.sh"
source "${QUICKVM_LIBS}/cloudInit.sh"


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

# MAIN

## DISK IMAGE
[ -d "$CONFIGDIR" ] || (echo "init config dir" >&2 && mkdir "$CONFIGDIR")

if [ ! -f "$DISKIMAGE" ]; then
    echo "downloading disk image from $DISKIMAGE_DOWNLOAD" >&2 && wget "$DISKIMAGE_DOWNLOAD" -O $DISKIMAGE
    validateImage "$DISKIMAGE_SIGNINGKEY" "$DISKIMAGE_CHECKSUM_URI" "$DISKIMAGE_CHECKSUM_SIG_URI" "$DISKIMAGE"
fi

## CLOUD INIT DATA
[ -d "$CLOUDINIT_DATA" ] || (echo "create cloudinit dir" >&2 && mkdir -p "$CLOUDINIT_DATA")
[ -d "$SSH_DIR" ] || (echo "create ssh dir" >&2 && mkdir -p "$SSH_DIR")

# ToDo: It should be checked whether VM was already created before doing this.
# If there is a pub key in cloud init that was already deployed to VM it must be checked that the required privkey is avail.
# For now only check that there is no priv key file yet
[ -f "${SSH_DIR}/${VMNAME}" ] || ssh-keygen -t ed25519 -f "${WORKDIR}/${SSH_DIR}/${VMNAME}" -P ""
[ -f "${SSH_DIR}/${VMNAME}-hostkey" ] || ssh-keygen -t ed25519 -f "${WORKDIR}/${SSH_DIR}/${VMNAME}-hostkey" -P "" -C "${VMNAME}"

if [ ! -f "${CLOUDINIT_DATA}/user-data" ]; then
    # read exits with non-zero exit code when encountering EOF.
    # ToDo: only catch "EOF" error-code
    IFS= read -rd '' HOSTKEY_ED25519_PRIV < "${SSH_DIR}/${VMNAME}-hostkey" || true
    addSSHKeys_ED25519 \
        "${TEMPLATES}/cloudinit/user-data.tpl" \
        "$(cat "${SSH_DIR}/${VMNAME}.pub")" \
        "$HOSTKEY_ED25519_PRIV" \
        "$(cat "${SSH_DIR}/${VMNAME}-hostkey.pub")" \
        > "${CLOUDINIT_DATA}/user-data"
fi

# ToDo: Use meta-data to set hostname for DNS
[ -f "${CLOUDINIT_DATA}/meta-data" ] || touch "${CLOUDINIT_DATA}/meta-data"

initVM

#virsh --connect qemu:///system console "${VMNAME}"

VMIP=""
while [ -z "${VMIP}" ]
do
    echo "Attempting to get VM IP..."
    # ToDo: More stable way to do this. What if more than one line is output?
    VMIP="$(virsh -q domifaddr "$VMNAME" | awk '{ print $4 }' | cut -d '/' -f 1)"
    sleep 2
done

# ToDo: Wait for ssh daemon
echo "Waiting ${CONNECTION_DELAY_SECONDS} seconds for VM to become available via ssh..." >&2
sleep "$CONNECTION_DELAY_SECONDS"

[ -f "${SSH_DIR}/known_hosts" ] || cat <(echo -n "$VMIP ") "${WORKDIR}/${SSH_DIR}/${VMNAME}-hostkey.pub" > "${SSH_DIR}/known_hosts"
ssh -i "${SSH_DIR}/${VMNAME}" -o "UserKnownHostsFile=${SSH_DIR}/known_hosts" developer@"${VMIP}"