// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BasicSwiftUtilities",
    platforms: [
        .iOS("10"),
        .macOS("11"),
        .tvOS("10"),
        .watchOS("3")
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "CoreHealth",
            targets: ["CoreHealth"]
        ),
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]
        ),
        .library(
            name: "CoreStorage",
            targets: ["CoreStorage"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: []
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
        
        .target(
            name: "CoreHealth",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "CoreHealthTests",
            dependencies: ["CoreHealth"]
        ),
        
        .target(
            name: "CoreUI",
            dependencies: []
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"]
        ),
        
        .target(
            name: "CoreStorage",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "CoreStorageTests",
            dependencies: ["CoreStorage"]
        ),
    ]
)
