# The Motion Spec (designers and developers)

> **Sources.** The brand-motion-identity and personality ideas come from the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles); the spec format, token files, and handoff rules are AppBootstrapAI's.

Motion gets lost between a prototype and code: a designer's 280 ms custom curve becomes `.default` and nobody notices until the app feels generic. The fix is a short written contract in the repo, `docs/design/motion.md`, that both sides edit, with values expressed as tokens that exist in code.

## `docs/design/motion.md` Template

```markdown
# Motion

## Personality
Calm / professional. Motion confirms and orients; it rarely celebrates.
Exceptions: purchase success and onboarding completion may use `celebrate`.

## Tokens
| Token     | Use                               | SwiftUI                         | Compose                                   |
|-----------|-----------------------------------|---------------------------------|-------------------------------------------|
| feedback  | Press, toggle, selection          | `.snappy(duration: 0.15)`       | `spring(0.85f, StiffnessMedium)`          |
| standard  | On-screen change                  | `.smooth(duration: 0.3)`        | `motionScheme.defaultSpatialSpec()`       |
| enter     | Content arriving                  | `.spring(duration: 0.35, bounce: 0.1)` | `tween(300, EmphasizedDecelerate)` |
| exit      | Content leaving                   | `.easeIn(duration: 0.2)`        | `tween(200, EmphasizedAccelerate)`        |
| effects   | Color and opacity                 | `.easeInOut(duration: 0.2)`     | `motionScheme.defaultEffectsSpec()`       |
| celebrate | Rare milestones only              | `.bouncy(duration: 0.4)`        | `spring(DampingRatioMediumBouncy)`        |

## Entrance pattern
Slide up 16 pt / dp + fade in, `enter`. Exits fade (+ slide down for dismissals), `exit`.

## Reduced motion
Spatial motion becomes a 150 ms crossfade. Loops and Lottie show a still frame.
Haptics and text still fire.

## Interactions
| Trigger | Element | Property | From → To | Token | Delay | Reduced | Also |
|---------|---------|----------|-----------|-------|-------|---------|------|
| Tap "Pay" succeeds | Check badge | scale, opacity | 0.9, 0 → 1, 1 | celebrate | 0 | fade | success haptic; "Payment complete" |
| Wrong passcode | Code field | x offset | 0 → ±10 → 0 (3 swings) | (shake recipe) | 0 | none | error haptic; error text |
| Row added | New row | y, opacity | +16, 0 → 0, 1 | enter | 50 ms | fade | — |

## Assets
| Name | File | Loops? | Still frame for reduced motion | Themed layers |
|------|------|--------|--------------------------------|---------------|
| success | `success.lottie` | no | last frame | `Fill_Primary` |
```

Rules for the spec:

- **Every row has a reduced alternative and a non-motion signal.** A row without them isn't done.
- **Values are tokens.** A designer who needs a new value adds a token (with a reason), not a one-off number.
- **Name things the way the code does** (screen and component names from the codebase; same names on both platforms, see `cross-platform-development.md` when both are in scope).
- **Prototypes are references, not sources of truth.** Figma Smart Animate, Rive, After Effects, and Lottie Creator previews are approximations; the token table is what ships.
- **Platform differences are declared, not accidental**: navigation, sheets, and back gestures follow each platform; custom moments match.

## Token Files

Swift (`DesignSystem/Motion.swift`):

```swift
import SwiftUI

public enum Motion {
    public static let feedback = Animation.snappy(duration: 0.15)
    public static let standard = Animation.smooth(duration: 0.3)
    public static let enter = Animation.spring(duration: 0.35, bounce: 0.1)
    public static let exit = Animation.easeIn(duration: 0.2)
    public static let effects = Animation.easeInOut(duration: 0.2)
    public static let celebrate = Animation.bouncy(duration: 0.4)
    /// What spatial motion becomes under Reduce Motion.
    public static let reduced = Animation.easeInOut(duration: 0.15)
}

public extension View {
    /// Animates `value` with `animation`, or a short crossfade-friendly ease under Reduce Motion.
    func motion<V: Equatable>(_ animation: Animation, value: V) -> some View {
        modifier(MotionModifier(animation: animation, value: value))
    }
}

private struct MotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: V
    func body(content: Content) -> some View {
        content.animation(reduceMotion ? Motion.reduced : animation, value: value)
    }
}
```

Kotlin (`:core:designsystem`, `AppMotion.kt`):

```kotlin
object AppMotion {
    val Standard = CubicBezierEasing(0.2f, 0f, 0f, 1f)
    val EmphasizedDecelerate = CubicBezierEasing(0.05f, 0.7f, 0.1f, 1f)
    val EmphasizedAccelerate = CubicBezierEasing(0.3f, 0f, 0.8f, 0.15f)

    fun <T> feedback(): FiniteAnimationSpec<T> = spring(dampingRatio = 0.85f, stiffness = Spring.StiffnessMedium)
    fun <T> standard(): FiniteAnimationSpec<T> = tween(300, easing = Standard)
    fun <T> enter(): FiniteAnimationSpec<T> = tween(300, easing = EmphasizedDecelerate)
    fun <T> exit(): FiniteAnimationSpec<T> = tween(200, easing = EmphasizedAccelerate)
    fun <T> effects(): FiniteAnimationSpec<T> = tween(200, easing = Standard)
    fun <T> celebrate(): FiniteAnimationSpec<T> = spring(dampingRatio = Spring.DampingRatioMediumBouncy)
}

/** True when the person turned system animations off ("Remove animations"). */
@Composable
fun rememberReducedMotion(): Boolean {
    val resolver = LocalContext.current.contentResolver
    return remember(resolver) {
        Settings.Global.getFloat(resolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) == 0f
    }
}
```

With Material 3 1.4+, prefer `MaterialTheme.motionScheme` for spatial and effects specs and keep `AppMotion` for the app-specific roles. Choose `MotionScheme.standard()` or `MotionScheme.expressive()` in `AppTheme`, once.

Add the tokens to the design-system gallery or catalog with a preview that plays each one, so designers can review them on device.

## Lottie and dotLottie Handoff

**Designers, when exporting:**

- Export **dotLottie (`.lottie`)**: compressed, and can bundle several animations and themes. Plain JSON is fine for tiny files.
- **Size budget**: aim for tens of KB per animation; flag anything over ~200 KB. Remove hidden layers and unused assets; avoid embedded raster images.
- **Avoid features players render poorly or slowly**: expressions, most After Effects effects, many mattes and masks, 3D layers, text layers (text belongs in the app so it's localized and Dynamic Type / font-scale aware). Preview in the LottieFiles player or Lottie Creator on a phone before handing off.
- **Name the layers code will theme** (`Fill_Primary`, `Stroke_Accent`) and keep those names stable.
- **Match the frame rate the design needs** (30 fps is often enough for illustrations, 60 for UI-coupled motion) and size the artboard at the aspect ratio it will display.
- **Say which frame is the still** for reduced motion, and whether it loops. Add a marker named `reduced_motion` if the player you target supports one.
- **Design for both appearances**: either theme colors from code, or deliver dark variants.

**Developers, when integrating:**

- One wrapper component per platform (`AnimatedIllustration` / `LottieIllustration`) owns loading, playback mode, reduced motion, theming, and accessibility. Feature code never calls Lottie directly.
- Play once for feedback, loop only for loading or ambient states, pause loops off screen and in the background.
- Hide decorative animations from VoiceOver / TalkBack; label meaningful ones with the outcome.
- Measure: a Lottie animation that drops frames on a mid-range Android phone or an older iPhone is a finding; simplify the file rather than the device list.
- Apple: `lottie-ios` (`LottieView`, `DotLottieFile`) through Swift Package Manager. Android: `lottie-compose` (`rememberLottieComposition`, `LottieAnimation`, `rememberLottieDynamicProperties`) through the version catalog. Check both libraries' release notes for reduced-motion support in the version you pin.
- For a simple icon change, prefer SF Symbol effects (`.symbolEffect`) or `AnimatedVectorDrawable` / `AnimatedImageVector` over a Lottie file.
