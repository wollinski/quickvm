#!/bin/bash

validateImage() {
    local KEYRING_PATH="$1"
    local CHECKSUM_URI="$2"
    local CHECKSUM_SIG_URI="$3"
    local IMAGE_PATH="$4"

    local CHECKSUMS="`curl "${CHECKSUM_URI}"`"
    local CHECKSUMS_SIG="`curl "${CHECKSUM_SIG_URI}"`"

    if gpgv --keyring "$KEYRING_PATH" <(echo "$CHECKSUMS_SIG") <(echo "$CHECKSUMS"); then
        # Within this block CHECKSUMS is trustworthy
        echo "signature validated succesfully" >&2
        # To avoid that the calculated checksum matches a substring of a signed checksum value it is matched as
        # "^<CHECKSUM> " with caret and trailing space!
        if grep "^`sha256sum "$IMAGE_PATH" | cut -d " " -f 1` " <(echo "$CHECKSUMS"); then
            echo "image validated successfully" >&2
            return 0
        fi
    fi

    echo "failed to verify image." >&2
    return 74
}