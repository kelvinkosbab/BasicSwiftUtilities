// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v11),
        .macOS("10.15"),
        .tvOS(.v13),
        .watchOS(.v6)
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
                 "8.0.0" ..< "9.0.0")
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
