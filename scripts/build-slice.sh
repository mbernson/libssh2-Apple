#!/bin/bash
# Builds a static libssh2 for one Apple platform against the matching slice of OpenSSL.xcframework.
# Usage: build-slice.sh <tarball> <macos|ios|iossimulator> <path/to/OpenSSL.xcframework> <output-dir>
# Produces <output-dir>/lib/libssh2.a and <output-dir>/include/*.h.
set -euo pipefail

TARBALL=$1
PLATFORM=$2
OPENSSL_XCFRAMEWORK=$3
OUTPUT_DIR=$4
MACOS_DEPLOYMENT_TARGET=${MACOS_DEPLOYMENT_TARGET:-10.13}
IOS_DEPLOYMENT_TARGET=${IOS_DEPLOYMENT_TARGET:-15.5}

# Xcode's build system rejects deployment targets older than it supports, so the plain Makefiles
# generator is used: clang itself accepts any version, and clamps arm64 macOS to 11.0 by itself.
case $PLATFORM in
	macos)
		openssl_slice=$(ls -d "$OPENSSL_XCFRAMEWORK"/macos-*)
		cmake_platform_args=(
			-DCMAKE_SYSTEM_NAME=Darwin
			-DCMAKE_OSX_SYSROOT=macosx
			-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
			-DCMAKE_OSX_DEPLOYMENT_TARGET="$MACOS_DEPLOYMENT_TARGET"
		)
		;;
	ios)
		openssl_slice=$(ls -d "$OPENSSL_XCFRAMEWORK"/ios-* | grep -v -- '-simulator$')
		cmake_platform_args=(
			-DCMAKE_SYSTEM_NAME=iOS
			-DCMAKE_OSX_SYSROOT=iphoneos
			-DCMAKE_OSX_ARCHITECTURES="arm64"
			-DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET"
			-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
		)
		;;
	iossimulator)
		openssl_slice=$(ls -d "$OPENSSL_XCFRAMEWORK"/ios-*-simulator)
		cmake_platform_args=(
			-DCMAKE_SYSTEM_NAME=iOS
			-DCMAKE_OSX_SYSROOT=iphonesimulator
			-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
			-DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET"
			-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
		)
		;;
	*)
		echo "Unknown platform '$PLATFORM'. Expected macos, ios or iossimulator." >&2
		exit 1
		;;
esac

mkdir -p "$OUTPUT_DIR/lib" "$OUTPUT_DIR/include"
SOURCE_DIR=$(mktemp -d -t libssh2-src)
BUILD_DIR=$(mktemp -d -t libssh2-build)
tar xzf "$TARBALL" -C "$SOURCE_DIR" --strip-components=1

cmake -S "$SOURCE_DIR" -B "$BUILD_DIR" -G "Unix Makefiles" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_STATIC_LIBS=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_TESTING=OFF \
	-DCRYPTO_BACKEND=OpenSSL \
	-DOPENSSL_INCLUDE_DIR="$openssl_slice/Headers" \
	-DOPENSSL_CRYPTO_LIBRARY="$openssl_slice/libopenssl.a" \
	-DOPENSSL_SSL_LIBRARY="$openssl_slice/libopenssl.a" \
	"${cmake_platform_args[@]}"
cmake --build "$BUILD_DIR" --parallel "$(sysctl -n hw.ncpu)"

cp "$(find "$BUILD_DIR" -name 'libssh2.a' -print -quit)" "$OUTPUT_DIR/lib/"
cp "$SOURCE_DIR"/include/*.h "$OUTPUT_DIR/include/"
