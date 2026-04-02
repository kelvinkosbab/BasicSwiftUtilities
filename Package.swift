// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Target Helpers

/// Shared Swift settings applied to all targets.
let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]

/// Creates a source target and optionally a test target for a module.
///
/// Assumes the directory layout:
/// ```
/// {name}/
///     Sources/
///     Tests/       (if hasTests is true)
/// ```
func makeTargets(
    name: String,
    dependencies: [Target.Dependency] = [],
    hasTests: Bool = true,
    testResources: [Resource]? = nil
) -> [Target] {
    var targets: [Target] = [
        .target(
            name: name,
            dependencies: dependencies,
            path: "\(name)/Sources",
            swiftSettings: sharedSwiftSettings
        )
    ]
    if hasTests {
        targets.append(
            .testTarget(
                name: "\(name)Tests",
                dependencies: [.byName(name: name)],
                path: "\(name)/Tests",
                resources: testResources,
                swiftSettings: sharedSwiftSettings
            )
        )
    }
    return targets
}

// MARK: - Package

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
        .library(name: "Core", targets: ["Core"]),
        .library(name: "CoreUI", targets: ["CoreUI"]),
        .library(name: "CoreUIKit", targets: ["CoreUIKit"]),
        .library(name: "CoreStorage", targets: ["CoreStorage"]),
        .library(name: "RunMode", targets: ["RunMode"])
    ],
    dependencies: [],
    targets: makeTargets(name: "Core")
        + makeTargets(name: "CoreUI")
        + makeTargets(name: "CoreUIKit", dependencies: ["CoreUI"], hasTests: false)
        + makeTargets(name: "CoreStorage", dependencies: ["Core"], testResources: [.process("Resources")])
        + makeTargets(name: "RunMode")
)
