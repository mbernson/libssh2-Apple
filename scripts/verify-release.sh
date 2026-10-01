#!/bin/bash
# Builds and runs a throwaway package that depends on a released version together with OpenSSL-Apple,
# proving that the artifact downloads, its headers are found and both libraries link on macOS, and that
# it builds for iOS Simulator.
# Usage: verify-release.sh <version> <openssl-version> [package-url]
set -euo pipefail

VERSION=$1
OPENSSL_VERSION=$2
PACKAGE_URL=${3:-https://github.com/mbernson/libssh2-Apple.git}
OPENSSL_PACKAGE_URL=${OPENSSL_PACKAGE_URL:-https://github.com/mbernson/OpenSSL-Apple.git}
PACKAGE_DIR=$(mktemp -d -t libssh2-verify)

mkdir -p "$PACKAGE_DIR/Sources/Verify"
cat > "$PACKAGE_DIR/Package.swift" <<MANIFEST
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Verify",
    platforms: [.macOS(.v11), .iOS("15.5")],
    dependencies: [
        .package(url: "$PACKAGE_URL", exact: "$VERSION"),
        .package(url: "$OPENSSL_PACKAGE_URL", exact: "$OPENSSL_VERSION"),
    ],
    targets: [
        .executableTarget(
            name: "Verify",
            dependencies: [
                .product(name: "libssh2", package: "libssh2-Apple"),
                .product(name: "OpenSSL", package: "OpenSSL-Apple"),
            ]
        ),
    ]
)
MANIFEST
cat > "$PACKAGE_DIR/Sources/Verify/main.c" <<'SOURCE'
#include <stdio.h>
#include <libssh2.h>

int main(void) {
	if (libssh2_init(0) != 0) {
		return 1;
	}
	printf("libssh2 %s\n", libssh2_version(0));
	libssh2_exit();
	return 0;
}
SOURCE

output=$(swift run --package-path "$PACKAGE_DIR" Verify)
echo "$output"
[[ $output == "libssh2 $VERSION"* ]] || { echo "Expected libssh2 $VERSION" >&2; exit 1; }

swift build --package-path "$PACKAGE_DIR" \
	--triple arm64-apple-ios15.5-simulator --sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)"
