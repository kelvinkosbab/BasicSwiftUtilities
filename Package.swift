// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Target Helpers

/// Shared Swift settings applied to all targets.
let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("InternalImportsByDefault")
]

/// Creates a source target and (optionally) a paired test target for a module.
///
/// Directory layout this assumes:
/// ```
/// {name}/
///     Sources/
///         Resources/   (only if hasResources is true)
///     Tests/           (only if hasTests is true)
/// ```
///
/// - Parameters:
///   - name: Module name. Used as both the target name and the on-disk folder.
///   - dependencies: Other targets / package products this module imports.
///     Use `"OtherModule"` for sibling targets in this package,
///     `.product(name: "X", package: "Y")` for external package products.
///   - hasTests: Whether to create a paired test target. Defaults to `true` —
///     missing tests is a problem to fix, not a configuration to support.
///     Set to `false` only for purely declarative resource-only targets.
///   - hasResources: When `true`, the source target picks up
///     `{name}/Sources/Resources/` via `.process("Resources")`. Use for
///     `.xcassets`, `.xcstrings`, `.json` data files, etc.
///   - testDependencies: Additional dependencies the test target needs
///     beyond the module-under-test (e.g., test fixtures from sibling
///     modules). The module-under-test is always included automatically.
///   - testResources: Resources for the test target (test fixtures, sample
///     payloads). Less common than source resources.
///   - plugins: Build-tool plugins attached to the source target (e.g.,
///     `SwiftLintBuildToolPlugin`). Test targets don't inherit these by
///     default — pass them explicitly here only if you want lint on source.
func makeTargets(
    name: String,
    dependencies: [Target.Dependency] = [],
    hasTests: Bool = true,
    hasResources: Bool = false,
    testDependencies: [Target.Dependency] = [],
    testResources: [Resource]? = nil,
    plugins: [Target.PluginUsage]? = nil
) -> [Target] {
    var targets: [Target] = [
        .target(
            name: name,
            dependencies: dependencies,
            path: "\(name)/Sources",
            resources: hasResources ? [.process("Resources")] : nil,
            swiftSettings: sharedSwiftSettings,
            plugins: plugins
        )
    ]
    if hasTests {
        targets.append(
            .testTarget(
                name: "\(name)Tests",
                dependencies: [.byName(name: name)] + testDependencies,
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
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "CoreUI", targets: ["CoreUI"]),
        .library(name: "CoreUIKit", targets: ["CoreUIKit"]),
        .library(name: "CoreStorage", targets: ["CoreStorage"]),
        .library(name: "LocalNetworkMonitor", targets: ["LocalNetworkMonitor"]),
        .library(name: "RunMode", targets: ["RunMode"])
    ],
    dependencies: [
        // SwiftLint as a build-tool plugin — lints every module on `swift build`.
        // Pinned with `from:` so consumers of *this* package don't get surprised
        // by SwiftLint rule-set bumps mid-release. The plugin runs locally and
        // in CI; CI is the authoritative gate (see .github/workflows/swift.yml).
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.63.2")
    ],
    targets: makeTargets(name: "Core", hasResources: true, plugins: swiftLintPlugins)
        + makeTargets(name: "CoreUI", plugins: swiftLintPlugins)
        + makeTargets(name: "CoreUIKit", dependencies: ["CoreUI"], plugins: swiftLintPlugins)
        + makeTargets(name: "CoreStorage", dependencies: ["Core"], testResources: [.process("Resources")], plugins: swiftLintPlugins)
        + makeTargets(name: "LocalNetworkMonitor", dependencies: ["Core"], plugins: swiftLintPlugins)
        + makeTargets(name: "RunMode", plugins: swiftLintPlugins)
)

// MARK: - Plugin Helpers

/// Build-tool plugins applied to every source target. SwiftLint is the only
/// entry today; future plugins (codegen, etc.) can be added here.
let swiftLintPlugins: [Target.PluginUsage] = [
    .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
]
