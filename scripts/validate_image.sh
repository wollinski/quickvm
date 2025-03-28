#!/bin/bash

# ToDo: This must be manually synced with the path in Makefile. Can this be improved?
: "${KEYRING_PATH:="/usr/local/share/quickvm/ubuntu-signingkey.gpg"}"

# ToDo: What is the correct path? Must be aligned with image download link.
: "${CHECKSUM_URI:="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"}"
: "${CHECKSUM_SIG_URI="https://cloud-images.ubuntu.com/noble/current/SHA256SUMS.gpg"}"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <image path>"
    exit 1
fi
IMAGE_PATH="$1"

CHECKSUMS="`curl "${CHECKSUM_URI}"`"
CHECKSUMS_SIG="`curl "${CHECKSUM_SIG_URI}"`"

if gpgv --keyring "$KEYRING_PATH" <(echo "$CHECKSUMS_SIG") <(echo "$CHECKSUMS"); then
    # Within this block CHECKSUMS is trustworthy
    echo "signature validated succesfully" >&2
    # To avoid that the calculated checksum matches a substring of a signed checksum value it is matched as
    # "^<CHECKSUM> " with caret and trailing space!
    if grep "^`sha256sum "$IMAGE_PATH" | cut -d " " -f 1` " <(echo "$CHECKSUMS"); then
        echo "image validated successfully" >&2
        exit 0
    fi
fi

echo "failed to verify image. exiting." >&2
exit 74