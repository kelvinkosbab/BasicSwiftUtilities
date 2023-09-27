// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BasicSwiftUtilities",
    platforms: [
        .iOS("15"),
        .macOS("12"),
        .tvOS("15"),
        .watchOS("7")
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
        .library(
            name: "RunMode",
            targets: ["RunMode"]
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
        
        .target(
            name: "RunMode",
            dependencies: []
        ),
        .testTarget(
            name: "RunModeTests",
            dependencies: ["RunMode"]
        ),
    ]
)
