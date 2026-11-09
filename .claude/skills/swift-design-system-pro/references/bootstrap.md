# Bootstrapping a DesignSystem module

Use this for a new app, or an existing app that has no shared UI module yet. The output is small on purpose: tokens, the icon facade, a few styles, and a gallery. Everything else grows from real repetition.

## 1. Create the module

With the bundle's scaffolder (from the AppBootstrapAI checkout, against the app repo):

```bash
scripts/scaffold-spm-package.sh <app-repo> --modules Core,DesignSystem,AppCore
```

Or, in an existing `makeTargets()` manifest (see `apple-spm-package-conventions.md`), add the module — resources on, depending on `Core` at most:

```swift
products: [
    // …
    .library(name: "DesignSystem", targets: ["DesignSystem"]),
],
targets:
    makeTargets(name: "Core")
    + makeTargets(name: "DesignSystem", dependencies: ["Core"], hasResources: true)
    // Feature modules add "DesignSystem" to their dependencies.
```

## 2. Files to generate

```
DesignSystem/
├── Sources/
│   ├── Tokens/
│   │   ├── ColorTokens.swift       # role-named colors (system first, brand from the catalog)
│   │   ├── Typography.swift        # role fonts → text styles; brand font registration
│   │   ├── Spacing.swift           # spacing + radius scale
│   │   └── Density.swift           # @Entry environment values for per-subtree variation
│   ├── Icons/
│   │   └── AppIcon.swift           # SF Symbol facade + custom symbol accessors
│   ├── Styles/
│   │   ├── ButtonStyles.swift      # .primary / .secondary / .destructive
│   │   └── LabelStyles.swift       # e.g. .rowIcon (fixed scaled tile + title)
│   ├── Components/
│   │   └── Card.swift              # first slot-based composite, only if needed now
│   ├── Gallery/
│   │   └── DesignSystemGallery.swift  # every token + component in one scrollable view
│   └── Resources/
│       └── DesignSystem.xcassets   # brand color sets (Any/Dark/High Contrast), custom symbols
└── Tests/
    └── AppIconTests.swift          # every AppIcon case resolves on the min deployment target
```

Skip any file the app doesn't need yet (no brand font → no registration; no custom symbols → no symbol sets).

## 3. Starter code

```swift
// ColorTokens.swift
public import SwiftUI

public extension ShapeStyle where Self == Color {
    // System-backed roles — adapt to appearance, contrast, and vibrancy for free.
    static var textPrimary: Color { .primary }
    static var textSecondary: Color { .secondary }
    static var surface: Color { Color(uiColor: .systemBackground) }
    static var surfaceElevated: Color { Color(uiColor: .secondarySystemBackground) }

    // Brand roles — asset-catalog color sets with Any/Dark/High Contrast variants.
    static var accentBrand: Color { Color("accentBrand", bundle: .module) }
}
```

(On macOS-only or multiplatform modules, use `Color(nsColor:)` equivalents or catalog color sets for every role.)

```swift
// Typography.swift
public import SwiftUI
import CoreText

public extension Font {
    static var screenTitle: Font { .largeTitle.weight(.bold) }
    static var cardTitle: Font { .headline }
    // Brand font that still scales with Dynamic Type:
    static var brandHeadline: Font { .custom("Brand-Semibold", size: 17, relativeTo: .headline) }
}

public enum DesignSystemFonts {
    /// Registers fonts shipped in this module. Call once at launch.
    public static func register() {
        for url in Bundle.module.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? [] {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
```

```swift
// Spacing.swift
public import CoreGraphics

public enum Spacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}
```

```swift
// AppIcon.swift
public import SwiftUI

public enum AppIcon: String, CaseIterable, Sendable {
    case settings = "gearshape"
    case delete = "trash"
    case share = "square.and.arrow.up"
    case favorite = "heart"
    case disclosure = "chevron.forward"
}

public extension Image {
    init(_ icon: AppIcon) { self.init(systemName: icon.rawValue) }
}

public extension Label where Title == Text, Icon == Image {
    init(_ title: LocalizedStringResource, icon: AppIcon) {
        self.init { Text(title) } icon: { Image(icon) }
    }
}
```

```swift
// AppIconTests.swift
import Testing
import UIKit
@testable import DesignSystem

@Suite("AppIcon")
struct AppIconTests {
    @Test("every icon resolves to a system symbol", arguments: AppIcon.allCases)
    func resolves(_ icon: AppIcon) {
        #expect(UIImage(systemName: icon.rawValue) != nil, "\(icon) → \(icon.rawValue) is missing on this OS")
    }
}
```

Run that test on the **minimum deployment target** simulator in CI; it's the only thing that catches a too-new symbol.

For button styles and environment values, start from the patterns in `apple-design-system.md` (`PrimaryButtonStyle`, `@Entry var density`).

```swift
// DesignSystemGallery.swift
public import SwiftUI

public struct DesignSystemGallery: View {
    public init() {}
    public var body: some View {
        List {
            Section("Buttons") {
                Button("Primary") {}.buttonStyle(.primary)
                Button("Primary (disabled)") {}.buttonStyle(.primary).disabled(true)
            }
            Section("Icons") {
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    Label(icon.rawValue, systemImage: icon.rawValue)
                }
            }
        }
    }
}

#Preview("Gallery") { DesignSystemGallery() }
#Preview("Gallery – AX5, dark") {
    DesignSystemGallery()
        .environment(\.dynamicTypeSize, .accessibility5)
        .preferredColorScheme(.dark)
}
```

(The gallery uses literal English and raw symbol names because it is a developer tool, not shipped UI — keep it `#if DEBUG` or out of the app's navigation.)

## 4. App icon

Create the icon in **Icon Composer** (`File ▸ New ▸ Icon` from Xcode 26+, or the standalone app): background layer + foreground layer group(s) from flat vector artwork, then tune Default / Dark / Clear / Tinted. Add the `.icon` file to the **app target** (not the package) and select it in the target's App Icon setting.

## 5. Audit searches (existing apps)

Run from the repo root; counts drive priority.

```bash
# Literal colors
rg -n --type swift 'Color\((red|white|hue):|UIColor\((red|white):|Color\(hex|#colorLiteral' | wc -l
# Fixed font sizes / non-scaling custom fonts
rg -n --type swift '\.system\(size:|Font\.custom\([^)]*size:[^)]*\)(?!.*relativeTo)|UIFont\.systemFont\(ofSize:' --pcre2 | wc -l
# Raw symbol strings outside the facade
rg -n --type swift 'systemName: "|systemImage: "' --glob '!**/DesignSystem/**' | wc -l
# Frame-sized symbols
rg -n --type swift -U 'systemName:[^\n]*\n?[^\n]*\.resizable\(\)' | wc -l
# Bundle.main asset loads inside packages
rg -n --type swift 'Image\("[^"]+"\)|Color\("[^"]+"\)' --glob '**/Sources/**' | rg -v 'bundle:' | wc -l
# Hand-rolled buttons and custom styles
rg -n --type swift '\.onTapGesture' | wc -l
rg -n --type swift ': (Primitive)?ButtonStyle' 
# Blockers for Liquid Glass on bars
rg -n --type swift 'UINavigationBarAppearance|UITabBarAppearance|toolbarBackground\(' 
rg -n 'UIDesignRequiresCompatibility' --glob '*.plist' --glob '*.xcconfig' --glob '*.pbxproj'
```

## 6. Migration playbook

1. **Scaffold the module with today's values** — tokens that resolve to the colors and fonts the app already uses, so nothing visibly changes. Ship that.
2. **Fix broken-tier issues first**: invisible-in-dark text, unlabeled icon-only buttons, wrapper "buttons" with no button traits, blank symbols.
3. **Migrate screen by screen** as features are touched: literals → tokens, raw symbols → `AppIcon`, local button looks → shared styles. Keep each PR one screen or one token family.
4. **Converge duplicates** per role (keep the most accessible implementation).
5. **Unblock Liquid Glass** — remove custom bar backgrounds when building with the current SDK; retire `UIDesignRequiresCompatibility`.
6. **Retheme last.** Once call sites read roles, a rebrand is an asset-catalog edit.
