---
name: swift-adaptive-layout-pro
description: Deep-reviews Apple apps for resizable-window and iPhone Duo readiness — the UIScene lifecycle mandate, size-class vs idiom/orientation branching, UIScreen.main and hardcoded-geometry removal, arrangements and hinge handling, vertical bars, Split View and multiple windows, scene accessories, asymmetric safe areas, state continuity across fold and resize, and Device Hub test coverage. Use when preparing an app for iPhone Duo or the iOS 27 resizability default, auditing iPad or iPhone multitasking and multi-window behavior, or reading, writing, or reviewing adaptive layout code in SwiftUI or UIKit.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.2"
  grounded_in: "Apple Developer Tech Talks 'Prepare your app for iPhone Duo', 'Raise the bar with iPhone Duo', 'Strike a pose with adaptive layouts on iPhone Duo', and 'Leverage multiple displays and scenes on iPhone Duo'; 'Preparing your app for iPhone Duo' docs; HIG 'Designing for iPhone Duo'; iOS 27.2 and Xcode 27.2 release notes; TN3192, TN3208; Apple's Xcode 27 app-resizability agent skill (as published by Artem Novichkov in artemnovichkov/xcode-skills)"
---

Review Apple app code for resizable-window and foldable readiness. This is the deep-review companion to the always-on `apple-adaptive-layout.md` rule — the rule steers while writing; this skill audits whole screens and the project's launch configuration. The Apple sibling of `android-adaptive-layout-pro`. Report only genuine problems; don't nitpick.

Applies to SwiftUI and UIKit (including Mac Catalyst). If asked to **write or fix** rather than review, make the changes directly and summarize them in the same file-by-file format.

Review process:

1. Check launch and resizability posture using `references/readiness-checklist.md` — the UIScene lifecycle mandate, `UIRequiresFullScreen`, Info.plist and project settings, SDK level.
2. Audit layout branching using `references/size-classes-and-idiom.md` — size classes vs idiom/orientation, `UIScreen.main` and global geometry, which containers already adapt.
3. Audit foldable-specific behavior using `references/duo-and-poses.md` — arrangements, hinge and reserved regions, vertical bars, safe-area asymmetry, state continuity across fold and resize.
4. Audit multitasking using `references/multitasking-and-scenes.md` — Split View and stacked layouts, multiple windows and their dynamic availability on Duo, per-scene state, scene accessories.
5. When fixing UIKit findings, apply the replacements in `references/uikit-api-replacements.md` — `UIScreen.main` scale and bounds, idiom and orientation branches, hardcoded safe-area values, and moving lifecycle methods to the scene delegate — one deprecation per change.

If doing a partial review, load only the relevant reference files.

## Core Instructions

- **Launch blockers outrank everything.** An app on the legacy app lifecycle doesn't launch against the latest SDK — find that first and report it above any styling finding. A Mac Catalyst target that uses iOS 27.1 APIs without `#if !targetEnvironment(macCatalyst)` doesn't build on Xcode 27.2; report it at the same tier.
- **The unit of adaptation is the window, not the device.** Any idiom check (`userInterfaceIdiom == .pad`), orientation check, or `UIScreen.main` read that drives layout is a finding regardless of how well it works on today's hardware — the iPhone Duo's inner display reports regular/regular while still being an iPhone.
- **Assume resizability is on.** Building against the iOS 27 SDK opts the app in; a layout that only works at one size is a bug waiting to ship, not a deliberate constraint. Flag the fixed-size assumption *and* whatever depended on it.
- **One app can have several windows, and each can be resized.** Duo brings multi-window and Split View to iPhone. Global "current window" or "current document" state is a finding.
- **A fold or resize is a configuration change.** Trace selection, scroll position, text entry, and in-flight work across it — state derived from an old size is the continuity bug users notice.
- **Prefer the system containers.** Hand-rolled `if regular { HStack } else { VStack }` isn't wrong, but when `NavigationSplitView`, `TabView`+sidebar placement, or an `ArrangementView` fits, recommend it — they handle resize and back-navigation the custom code usually forgets.
- **Severity by user impact**: broken (won't launch, unusable layout, state loss on fold, stretched camera preview) > degraded (phone layout stretched wide, sidebar never shown on a regular-width display, symmetric safe-area math) > polish (missing concentric corners, unexercised poses).
- Cross-reference rather than duplicate: VoiceOver/keyboard semantics belong to `swift-accessibility-pro`; general SwiftUI API modernity to `swiftui-pro`.

## Output Format

Organize findings by file. For each issue: file/line, the violated principle, the context(s) affected (iPhone Duo folded / unfolded / Split View / second window / iPad multitasking / resize / Mac Catalyst), and a brief before/after. Skip clean files. End with a prioritized summary, launch-blocking and broken-tier issues first.

Example finding:

### FeedViewController.swift

**Line 34: idiom check drives the layout — wrong on iPhone Duo's inner display and in iPad multitasking.**

```swift
// Before
if UIDevice.current.userInterfaceIdiom == .pad {
    showSidebar()
}

// After — branch on the space the window actually has
if traitCollection.horizontalSizeClass == .regular {
    showSidebar()
}
```

### Summary

1. **Launch-blocking:** app declares only the legacy lifecycle (no `UIScene` manifest) — will not launch against the latest SDK.
2. **Broken:** `UIScreen.main.bounds` sizes the camera preview in `CaptureView.swift` — stretched on the inner display.
3. **Degraded:** 4 idiom checks; symmetric safe-area math in `HeaderView.swift`.
4. **Polish:** no hinge handling on the media player, where tabletop posture would help.

End of example.

## References

- `references/readiness-checklist.md` — UIScene mandate, `UIRequiresFullScreen` semantics, SDK-level behavior, project/Info.plist audit, Device Hub and Previews test coverage.
- `references/size-classes-and-idiom.md` — size-class branching, the idiom/orientation/`UIScreen.main` removals, local geometry, which system containers adapt for free.
- `references/duo-and-poses.md` — `ArrangementView` / `UIArrangementViewController`, hinge and reserved regions, vertical bars, asymmetric safe areas, camera coordinators, state continuity across fold.
- `references/multitasking-and-scenes.md` — Split View and stacked layouts, multiple windows and activation availability, per-scene state, `sceneAccessory` / `CameraCaptureAccessory`.
- `references/adaptive-layout-conventions.md` — the full `apple-adaptive-layout` rule (the installed rule is its checklist). Load it when a finding needs the rule's exact wording or code, or the Xcode 27.2 testing notes.
