# libssh2 for Apple platforms

Prebuilt static libssh2 as an XCFramework, distributed as a Swift package with a binary target.
Every release is built on GitHub Actions from the official libssh2 release tarball, with OpenSSL as the crypto backend.

## Usage

The package version is the libssh2 version. libssh2 is compiled against the OpenSSL XCFramework from [OpenSSL-Apple](https://github.com/mbernson/OpenSSL-Apple), so link both:

```swift
dependencies: [
    .package(url: "https://github.com/mbernson/OpenSSL-Apple.git", from: "4.0.3"),
    .package(url: "https://github.com/mbernson/libssh2-Apple.git", from: "1.11.1"),
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            .product(name: "OpenSSL", package: "OpenSSL-Apple"),
            .product(name: "libssh2", package: "libssh2-Apple"),
        ]
    ),
]
```

C targets can then `#include <libssh2.h>`.

## Contents

| Platform | Architectures | Minimum OS |
|---|---|---|
| macOS | arm64, x86_64 | 11.0 (arm64), 10.13 (x86_64) |
| iOS | arm64 | 15.5 |
| iOS Simulator | arm64, x86_64 | 15.5 |

Built with `-DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DCRYPTO_BACKEND=OpenSSL`, without examples or tests. 
The libssh2 license is included in the XCFramework as `COPYING`. Each release's notes state which OpenSSL version it was compiled against.

## Releasing a new version

Open Actions → Release → Run workflow and enter the libssh2 version and the OpenSSL-Apple release to compile against. The workflow:

1. Builds the macOS, iOS and iOS Simulator slices in parallel, each against the matching slice of the downloaded `OpenSSL.xcframework`.
2. Bundles them into `libssh2.xcframework` and zips it.
3. Writes the asset URL and SPM checksum into `Package.swift` and commits that.
4. Creates the GitHub release, tagged with the version, with the zip attached.
5. Builds and runs an example package depending on the new version and on OpenSSL-Apple, to confirm the artifact downloads, compiles and links (`scripts/verify-release.sh`).

The asset URL is derived from the tag, so the manifest committed in step 3 is already correct before the release exists. A version can only be released once. To rebuild it, delete the release and its tag first. After releasing a new OpenSSL, rebuild libssh2 against it the same way.

## Building locally

```sh
scripts/download-source.sh 1.11.1 build
scripts/download-openssl.sh 4.0.3 build/openssl
scripts/build-slice.sh build/libssh2-1.11.1.tar.gz macos build/openssl/OpenSSL.xcframework slices/macos
scripts/build-slice.sh build/libssh2-1.11.1.tar.gz ios build/openssl/OpenSSL.xcframework slices/ios
scripts/build-slice.sh build/libssh2-1.11.1.tar.gz iossimulator build/openssl/OpenSSL.xcframework slices/iossimulator
scripts/create-xcframework.sh slices path/to/COPYING libssh2.xcframework
scripts/verify-release.sh 1.11.1 4.0.3
```
