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
            path: "Core/Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Core/Tests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - CoreUI

        .target(
            name: "CoreUI",
            dependencies: [],
            path: "CoreUI/Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"],
            path: "CoreUI/Tests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - CoreUIKit

        .target(
            name: "CoreUIKit",
            dependencies: ["CoreUI"],
            path: "CoreUIKit/Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),

        // MARK: - CoreStorage

        .target(
            name: "CoreStorage",
            dependencies: ["Core"],
            path: "CoreStorage/Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "CoreStorageTests",
            dependencies: ["CoreStorage"],
            path: "CoreStorage/Tests",
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
            path: "RunMode/Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "RunModeTests",
            dependencies: ["RunMode"],
            path: "RunMode/Tests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
