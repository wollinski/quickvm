#!/bin/bash

addSSHKeys_ED25519() {
    local USERDATA_TEMPLATE="$1"
    local SSH_PUBKEY="$2"
    local HOSTKEY_ED25519_PRIV="$3"
    local HOSTKEY_ED25519_PUB="$4"

    env \
        SSH_PUBKEY="$SSH_PUBKEY" \
        HOSTKEY_ED25519_PRIV="$HOSTKEY_ED25519_PRIV" \
        HOSTKEY_ED25519_PUB="$HOSTKEY_ED25519_PUB" \
        yq e '.ssh_keys.ed25519_private = strenv(HOSTKEY_ED25519_PRIV) |
            .ssh_keys.ed25519_public = strenv(HOSTKEY_ED25519_PUB) |
            .users[0].ssh_authorized_keys[0] = strenv(SSH_PUBKEY)' \
            "$USERDATA_TEMPLATE"
}