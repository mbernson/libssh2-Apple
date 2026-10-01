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
            url: "https://github.com/mbernson/libssh2-Apple/releases/download/1.11.1/libssh2.xcframework.zip",
            checksum: "110d85c6e2ce1630bcf82b91d2861686c6eb00f735289134e67f78836a53d7d3"
        ),
    ]
)
