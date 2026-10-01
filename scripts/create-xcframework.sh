#!/bin/bash
# Bundles the per-platform static libraries into an XCFramework.
# Usage: create-xcframework.sh <slices-dir> <license-file> <output.xcframework>
# <slices-dir> holds one directory per platform (macos, ios, iossimulator) as produced by build-slice.sh.
set -euo pipefail

SLICES_DIR=$1
LICENSE_FILE=$2
OUTPUT=$3

create_args=()
for slice in "$SLICES_DIR"/*/; do
	create_args+=(-library "$slice/lib/libssh2.a" -headers "$slice/include")
done

rm -rf "$OUTPUT"
xcodebuild -create-xcframework "${create_args[@]}" -output "$OUTPUT"
cp "$LICENSE_FILE" "$OUTPUT/COPYING"
