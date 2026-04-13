// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "rgn",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "rgn"
        ),
        .testTarget(
            name: "rgnTests",
            dependencies: ["rgn"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
