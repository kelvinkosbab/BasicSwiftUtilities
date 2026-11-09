# Launch & resizability readiness

> Launch-screen, iPad-orientation, and `UIRequiresFullScreen` handling also draw on Apple's Xcode 27 app-resizability agent skill, as published by [Artem Novichkov](https://github.com/artemnovichkov) in [`artemnovichkov/xcode-skills`](https://github.com/artemnovichkov/xcode-skills).

Audit this first. A layout finding is moot if the app doesn't launch, and the resizability posture determines whether every other finding is theoretical or shipping today.

## The UIScene mandate (launch-blocking)

Apps that still declare **only** the legacy app lifecycle **will not launch** when built against the latest SDKs. This is the highest-severity finding in the whole review.

What to check:

- `Info.plist` declares `UIApplicationSceneManifest` with at least one scene configuration.
- An `App`/`UISceneDelegate` (or SwiftUI `App` with `WindowGroup`) actually owns window setup — not `AppDelegate.window` assignment left over from the pre-scene era.
- Leftovers that signal a half-migration: `application(_:didFinishLaunchingWithOptions:)` creating a `UIWindow`, `UIApplication.shared.keyWindow` reads, `appDelegate.window` references across the codebase.
- SwiftUI apps are scene-based by construction — but a SwiftUI app wrapping a UIKit `AppDelegate` via `@UIApplicationDelegateAdaptor` can still carry legacy window code worth flagging.

## `UIRequiresFullScreen` is no longer an opt-out

Under iOS 27 on iPhone, `UIRequiresFullScreen` is honored as **discrete resizing**: on each size change the system transitions the scene to a new screen configuration matching that size, honoring supported orientations, so content renders at full quality in the space available.

- Its legitimate use is **rendering quality for games** and similar full-surface renderers — not "we don't want to adapt."
- If the key is present, the finding is usually *what it was protecting*: a layout that assumes one size. Report both.
- Don't recommend adding it to dodge adaptive work.
- **Leave the key, and `UIRequiresFullScreenIgnoredStartingWithVersion`, exactly as you found them.** TN3192 (*Migrating your app from the deprecated UIRequiresFullScreen key*) covers the migration. Deleting `UIRequiresFullScreen` makes the app resizable at once, before its layouts are ready; adding the `IgnoredStartingWithVersion` key picks which releases keep the old behavior, which is the developer's call (a value of 27 or lower makes the app fully resizable on iOS 27). Report the key and what it protects; the key comes out only after someone has run the app and resized every screen.

## SDK level determines how much screen you get

The app runs on iPhone Duo without recompiling, but the experience improves with the SDK you build against:

| Built against | Behavior |
|---|---|
| Pre-iOS 27 | Runs; conservative use of the inner display |
| **iOS 27** | **Resizable by default**; content extends left of the status bar on the inner display |
| **iOS 27.1** | Content reaches the screen edge; vertical bar layout; `ArrangementView`, `onHingeChange` / `UIHingeInteraction`, and reserved regions available — the Duo-ready level. **`UIView` default layout margins become zero.** |
| **iOS 27.2** (Xcode 27.2) | Mainline SDK with every 27.1 API; no new Duo APIs. The toolchain to pin. |

**Linking the iOS 27.1+ SDK changes UIKit layout margins.** Plain `UIView`s now default to zero layout margins; only a view controller's root view keeps `systemMinimumLayoutMargins`. Grep for `layoutMarginsGuide` and `directionalLayoutMargins` reads in subviews that don't set `preservesSuperviewLayoutMargins = true`. Content that used to sit inset now touches the edge. This is a degraded-tier finding that appears with no code change.

**Mac Catalyst targets.** In Xcode 27.2, iOS 27.1 APIs fail to compile for Catalyst, and a Catalyst deployment target of 27.1 or 27.2 misbehaves. Check that Duo code is wrapped in `#if !targetEnvironment(macCatalyst)` and the Catalyst minimum stays at 27.0 or lower.

Report the project's deployment target and SDK alongside findings — "this is fine today because you build against iOS 26" is real context, and so is "you're on the iOS 27 SDK, so resizability is already live for your users."

## Project & Info.plist audit

- **Orientation keys**: `UISupportedInterfaceOrientations` still matters for discrete resizing and the outer display, but the inner display does not honor it for resizable apps. A portrait-only declaration is not a layout strategy.
- **Launch screen (upload-blocking)**: the target must set one of `UILaunchScreen`, `UILaunchScreens`, `UILaunchStoryboardName`, `UILaunchStoryboards`, or `INFOPLIST_KEY_UILaunchScreen_Generation`. With none, an iOS 27 App Store upload is rejected with `ITMS-90870` (TN3208). One key is enough; leave an existing storyboard alone. A launch screen that hardcodes sizes also shows as a mis-sized flash on unfold.
- **iPad orientations**: the iPad declaration (`UISupportedInterfaceOrientations~ipad`, or the plain key when that's absent) should list all four orientations, or declare none. Name the missing ones, and note that a `supportedInterfaceOrientations` override can still lock the scene. A portrait-only *iPhone* declaration is normal.
- **Scene manifest**: multi-scene support (`UIApplicationSupportsMultipleScenes`) affects iPad and Duo multitasking behavior — check it matches the app's intent rather than being an accidental default.
- **Asset catalogs**: image sets keyed to specific device sizes rather than scale/appearance are a smell on a device with two displays.

## Test coverage

- **Device Hub** (Xcode 27) replaced the separate Simulator and Devices & Simulators windows. It rotates, screenshots, toggles dark mode, changes font size, **resizes freely by dragging edges**, and launches onto connected hardware. **Xcode Previews gained the same resize mode**, plus a Display group for previewing on an alternative display — size-class branches can be exercised without booting a simulator.
- **iPhone Duo simulator.** Install the iPhone Duo runtime via Settings ▸ Components (Xcode 27.2 recommended), then select iPhone Duo as a normal build destination. Toolbar buttons fold/unfold; **hold ⌥ Option for a precise hinge-angle slider**. A review should name which poses were exercised: folded, unfolded, partially open, each orientation, Split View on each side, a second window, free resize.
- **Xcode 27.2 Device Hub** adds StandBy on Duo, multi-finger touch through Sidecar or a touchscreen Mac, and hardware-keyboard simulation. Known Duo issues: VoiceOver and the Accessibility Inspector can't read its screen (do accessibility passes on a device), screenshots may be black for a few minutes after boot, and modifier keys can stop after an outer↔inner switch.
- **The recipe that finds real bugs**: navigate several screens deep, open a sheet, start typing — *then* fold and unfold while it's live, in both directions. Most continuity findings only appear this way.
- **What the simulator cannot cover** — flag these as device-only rather than letting a simulator pass stand in: camera transitions between outer / inner / rear cameras, one-handed reachability in partially folded poses, haptics, thermal behavior, and the physical appearance of the fold.
- **Xcode 27.1's "App Resizability" coding-agent skill** (renamed from "App Modernization") auto-detects and fixes common resizability issues in SwiftUI and UIKit. Recommend it as a first pass on a large legacy codebase — then review its edits; it is an agent, not an oracle.
- Build TestFlight candidates with Xcode 27.2: it carries the Duo APIs in the mainline SDK, so one toolchain covers Duo and every other device.
- Where the project has UI tests, suggest launching at more than one window size rather than asserting against a single fixed geometry.

## Audit sequence

1. Scene manifest + legacy-window code → launch-blocking findings. Missing launch screen → upload-blocking. Catalyst build with unguarded 27.1 APIs → build-breaking.
2. `UIRequiresFullScreen` and orientation keys → what fixed-size assumption do they protect?
3. Deployment target / SDK → how live are these findings for users today?
4. Launch screen + asset catalogs → mis-sized first frame. UIKit layout-margin reads → content against the edge on the 27.1+ SDK.
5. Name the untested poses and window sizes.
