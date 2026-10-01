#!/bin/bash
# Downloads the libssh2 release tarball into <dir> and records its SHA-256 next to it.
# libssh2 publishes GPG signatures rather than checksums, so the hash is recorded for the release notes, not verified.
# Usage: download-source.sh <version> <dir>
set -euo pipefail

VERSION=$1
DIR=$2
TARBALL="libssh2-$VERSION.tar.gz"

mkdir -p "$DIR"
cd "$DIR"
curl -fsSLO "https://github.com/libssh2/libssh2/releases/download/libssh2-$VERSION/$TARBALL"
shasum -a 256 "$TARBALL" > "$TARBALL.sha256"
