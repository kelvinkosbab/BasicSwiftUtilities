// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BasicSwiftUtilities",
    platforms: [
        .iOS("17"),
        .macOS("14"),
        .tvOS("17"),
        .watchOS("10"),
        .visionOS("1")
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]
        ),
        .library(
            name: "CoreUIKit",
            targets: ["CoreUIKit"]
        ),
        .library(
            name: "CoreStorage",
            targets: ["CoreStorage"]
        ),
        .library(
            name: "RunMode",
            targets: ["RunMode"]
        )
    ],
    dependencies: [],
    targets: [

        // MARK: - Core

        .target(
            name: "Core",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - CoreUI

        .target(
            name: "CoreUI",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - CoreUIKit

        .target(
            name: "CoreUIKit",
            dependencies: ["CoreUI"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - CoreStorage

        .target(
            name: "CoreStorage",
            dependencies: ["Core"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CoreStorageTests",
            dependencies: ["CoreStorage"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - RunMode

        .target(
            name: "RunMode",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "RunModeTests",
            dependencies: ["RunMode"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
