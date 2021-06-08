// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v11),
        .macOS("10.14")
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]),
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]),
        .library(
            name: "CoreAuthentication",
            targets: ["CoreAuthentication"])
    ],
    dependencies: [
        .package(name: "Firebase",
                 url: "https://github.com/firebase/firebase-ios-sdk.git",
                 .branch("7.7.0"))
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: []),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
        
        .target(
            name: "CoreUI",
            dependencies: ["Core"]),
        .testTarget(
            name: "CoreUITests",
            dependencies: ["CoreUI"]),
        
        .target(
            name: "CoreAuthentication",
            dependencies: [
                "Core",
                .product(name: "FirebaseAuth", package: "Firebase")
            ]),
        .testTarget(
            name: "CoreAuthenticationTests",
            dependencies: ["CoreAuthentication"]),
    ]
)
