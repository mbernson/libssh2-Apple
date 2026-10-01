#!/bin/bash
# Downloads a released OpenSSL.xcframework from OpenSSL-Apple and extracts it into <dir>.
# Usage: download-openssl.sh <openssl-version> <dir>
set -euo pipefail

VERSION=$1
DIR=$2
REPO=${OPENSSL_APPLE_REPO:-mbernson/OpenSSL-Apple}

mkdir -p "$DIR"
curl -fsSL -o "$DIR/OpenSSL.xcframework.zip" "https://github.com/$REPO/releases/download/$VERSION/OpenSSL.xcframework.zip"
ditto -x -k "$DIR/OpenSSL.xcframework.zip" "$DIR"
