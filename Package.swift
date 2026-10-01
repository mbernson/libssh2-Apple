// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "libssh2",
    platforms: [
        .macOS(.v10_13),
        .iOS("15.5"),
    ],
    products: [
        .library(name: "libssh2", targets: ["libssh2"]),
    ],
    targets: [
        // The release workflow rewrites `url` and `checksum` for every release.
        // Consumers must also link OpenSSL from https://github.com/mbernson/OpenSSL-Apple.
        .binaryTarget(
            name: "libssh2",
            url: "https://github.com/mbernson/libssh2-Apple/releases/download/0.0.0/libssh2.xcframework.zip",
            checksum: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
    ]
)
