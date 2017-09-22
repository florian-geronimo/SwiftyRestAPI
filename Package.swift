// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyRestAPI",
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/nsomar/Swiftline.git",
            from: "0.5.0"
        ),
    ],
    targets: [
        .target(
            name: "SwiftyRestAPI",
            dependencies: ["SwiftyRestAPICore"]
        ),
        .target(
            name: "SwiftyRestAPICore",
            dependencies: ["Files"]
        ),
        .testTarget(
          name: "SwiftyRestAPITests",
          dependencies: ["SwiftyRestAPICore", "Files"]
        )
    ]
)
