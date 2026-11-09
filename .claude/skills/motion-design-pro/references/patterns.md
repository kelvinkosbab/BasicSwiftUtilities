# Motion Patterns

> **Sources.** Recipes adapted from `patterns/` in the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles), rewritten for SwiftUI and Jetpack Compose. Values are starting points in the calm personality; scale them with `timing-and-easing.md`.

Every recipe lists its reduced-motion alternative. `Motion.*` (Swift) and `AppMotion.*` (Kotlin) are the token files from `motion-spec.md`.

## Choosing the Property

| Goal | Primary | Supporting | Avoid |
|------|---------|------------|-------|
| Enter / exit | Position | Opacity | Rotation |
| Press | Scale | Color | Position |
| Hover (pointer) | Scale or highlight | Shadow | Position |
| Success | Scale | Color, checkmark draw | Position |
| Error | Horizontal shake | Color | Scale |
| Loading | Rotation or shimmer | Opacity | Position |
| Toggle | Position (thumb) | Track color | Rotation |
| Delete | Scale + opacity | Siblings close the gap | Growing |
| Selection | Scale | Color | Rotation |

Opacity alone is fine for a quiet crossfade (and is the reduced-motion default), but an important state change needs a second cue: movement, scale, an icon, or text.

## Entrances and Exits

| Strategy | Start → end | Duration | Best for |
|----------|-------------|----------|----------|
| Slide in | 16–40 pt/dp offset + 0 opacity → rest | 200–300 ms, decelerate | Rows, banners, toasts |
| Scale in | 90–95% + 0 opacity → 100% | 250–350 ms | Dialogs, popovers, menus, cards |
| Reveal | Clip or mask grows | 300–450 ms | Images, hero media |
| Assemble | Parts arrive 50–100 ms apart | 300–600 ms total | Logos, onboarding, charts |

Exits: slide or fade out in 150–250 ms with an accelerating curve; delete with scale to 90% + fade, then close the gap; "move to" (add to cart, save to folder) travels toward its destination while shrinking, 250–400 ms in-out. Arrival direction carries meaning: from below for new content, from the trailing edge for forward navigation, from above for things dropped from the top (menus, banners).

```swift
// SwiftUI: banner slides down from the top
if isShown {
    Banner(message)
        .transition(reduceMotion ? .opacity
                    : .move(edge: .top).combined(with: .opacity))
}
// …toggled with: withAnimation(Motion.enter) { isShown = true }
```

```kotlin
// Compose: banner slides down from the top
AnimatedVisibility(
    visible = shown,
    enter = if (reduced) fadeIn(AppMotion.effects()) else fadeIn(AppMotion.effects()) + slideInVertically(AppMotion.enter()) { -it },
    exit = if (reduced) fadeOut(AppMotion.effects()) else fadeOut(AppMotion.effects()) + slideOutVertically(AppMotion.exit()) { -it },
) { Banner(message) }
```

Reduced: crossfade only.

## Press, Hover, Focus, Toggle

- **Press**: scale to 0.97 in 60–80 ms, back to 1.0 with a spring in 100–150 ms. Playful apps may overshoot to 1.03; premium apps dim to 90% opacity instead of scaling. In SwiftUI do it in a `ButtonStyle` reading `configuration.isPressed`; in Compose read `interactionSource.collectIsPressedAsState()` and apply the scale in `graphicsLayer`. Reduced: keep the color change, drop the scale.
- **Hover** (iPad pointer, Mac, Android desktop windows): in under 100 ms, out in 150–200 ms. Buttons scale 1.02–1.05 or highlight; cards lift 1–2% with a shadow. On Apple, `.hoverEffect` and the system pointer effects come first.
- **Focus** (keyboard, TV): the ring appears in about 150 ms and must work with motion reduced; on tvOS and Android TV the system focus effect is the default.
- **Toggle**: thumb moves in 120–180 ms in-out while the track color changes; playful styles may squash slightly. Use the system `Toggle` / `Switch` unless the design requires otherwise.

## Success, Error, Warning

- **Success**: container pops from 90% to 100% with a small bounce (200 ms), checkmark draws 100 ms later (150 ms), color shifts toward success (200 ms), plus a success haptic and text. Total 400–500 ms. Confetti only for rare milestones. Reduced: checkmark and color appear with a fade.
- **Error shake**: horizontal ±8–12 pt/dp, 2–3 shrinking swings, 300–400 ms, no overshoot, ends exactly at rest, with error color, an icon, the message, and an error haptic. Reduced: no shake; the message fades in.
- **Inline validation**: message slides down and fades in (200 ms), border turns to the error color (150 ms), icon scales in 50 ms later; on submit, scroll to the first invalid field (300 ms in-out). Reduced: no slide, no scroll animation.
- **Warning**: amber border (150 ms) and icon with a slight settle; optionally one slow pulse, never a continuous one.

```swift
// SwiftUI shake with shrinking swings, driven by an attempt counter (iOS 17+)
field
    .keyframeAnimator(initialValue: 0.0, trigger: failedAttempts) { content, x in
        content.offset(x: reduceMotion ? 0 : x)
    } keyframes: { _ in
        KeyframeTrack {
            CubicKeyframe(10, duration: 0.07)
            CubicKeyframe(-8, duration: 0.07)
            CubicKeyframe(5, duration: 0.07)
            CubicKeyframe(-3, duration: 0.07)
            CubicKeyframe(0, duration: 0.07)
        }
    }
    .sensoryFeedback(.error, trigger: failedAttempts)
```

```kotlin
// Compose shake
val offsetX = remember { Animatable(0f) }
LaunchedEffect(failedAttempts) {
    if (failedAttempts == 0 || reduced) return@LaunchedEffect
    for (x in listOf(10f, -8f, 5f, -3f, 0f)) offsetX.animateTo(x, tween(70))
}
TextField(modifier = Modifier.graphicsLayer { translationX = offsetX.value.dp.toPx() }, /* … */)
```

## Loading

| Pattern | Motion | Reduced |
|---------|--------|---------|
| Spinner | Linear rotation, 1–1.5 s per turn (use `ProgressView` / `CircularProgressIndicator`) | System indicators adapt; custom ones show a static glyph and text |
| Skeleton | Highlight sweeps across in 1.5–2 s, base 10–20% opacity, peak 30–40% | Static placeholder, no sweep |
| Progress bar | Width or scale in-out; determinate whenever possible | Instant updates |
| Indeterminate bar | Oscillation 1.5–2.5 s, never frantic | System indicator |

Show nothing for the first ~300 ms of a load; flashing a spinner for 100 ms feels slower than none.

## Ambient Motion

Use sparingly: onboarding, empty states, a rare hero. Ambient motion stops entirely when motion is reduced, when the app is in the background, and in Low Power Mode or battery saver if it's continuous.

| Effect | Range | Cycle |
|--------|-------|-------|
| Breathing pulse | Scale 0.98–1.02 or opacity 0.8–1.0 (beyond ±5% demands attention) | 2–4 s, sine |
| Float | ±5–10 pt/dp vertical, optional ±2° tilt | 3–5 s, sine; give multiple elements different periods so they never sync |
| Gradient drift | ±10–20% position or ±15° | 8–20 s, linear or sine |
| Shimmer on a "new" badge | Sweep with 0 → 30% → 0 opacity | 1.5–2.5 s sweep, 2–5 s pause |
| Parallax | Background ≤ 0.2× scroll speed, total travel < 100 pt/dp; never on text | Scroll-linked |

Keep ambient elements under ~20 and use transforms and opacity only.

## Multi-Element Sequences

**List or grid load**: rows slide up 16 pt/dp and fade in 200 ms, 40–60 ms apart, only the first screenful; grid cards scale from 95% in reading order. Reduced: everything fades in together.

```swift
ForEach(Array(items.prefix(8).enumerated()), id: \.element.id) { index, item in
    Row(item)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared || reduceMotion ? 0 : 16)
        .animation(Motion.enter.delay(reduceMotion ? 0 : Double(index) * 0.05), value: appeared)
}
```

```kotlin
itemsIndexed(items) { index, item ->
    val visible = remember { MutableTransitionState(false) }.apply { targetState = true }
    AnimatedVisibility(
        visibleState = visible,
        enter = fadeIn(tween(200, delayMillis = if (reduced) 0 else minOf(index, 8) * 50)) +
            if (reduced) EnterTransition.None else slideInVertically(tween(200, delayMillis = minOf(index, 8) * 50)) { it / 4 },
    ) { Row(item) }
}
```

Run row entrances once per load, not every time a row scrolls back into view. The Compose sketch replays when a row re-enters composition; hoist the set of already-shown keys to the list's state when that matters.

**Dialog with content**: scrim dims (200 ms) → container scales 95% → 100% (300 ms, 50 ms later) → title, body, buttons fade in 60–80 ms apart. Prefer the system dialog; this is for custom ones.

**Dashboard**: placeholders visible → hero metric at 100 ms → supporting cards 60 ms apart → charts draw → all settled by ~500 ms.

**Tab or segment switch**: indicator slides (250 ms in-out) while old content fades (150 ms); new content enters from the side of the selected tab 100 ms later.

**Expand / collapse**: chevron rotates (150 ms), height grows (250 ms), content fades in 50 ms after; collapsing reverses with an accelerating curve. `animateContentSize()` or a `DisclosureGroup` covers most cases.

**Drag and drop**: lift on pickup (scale 1.03, shadow up, 150 ms, with a haptic), neighbors shift (200 ms), settle on drop (200 ms).

**Item added to a list**: neighbors shift (200 ms in-out), the new item slides and fades in 50 ms later with a 3–5% settle. Use `Modifier.animateItem()` in Compose and an animated data change in SwiftUI.

## Choreography Rules

- **Lead with the hero**; supporting elements are subtler in every dimension.
- **One origin**: everything in a sequence enters from the same side or radiates from the trigger.
- **Shared trigger, staggered landing**: elements reacting to one event start within 50 ms of each other and may land at different times.
- **Counter-motion** adds depth on hero moments: when the hero lifts, its shadow spreads and softens; when it expands, siblings compress; backgrounds move 20–30% as far in the opposite direction.
- **Overlap sets the tempo**: no overlap feels methodical, ~25% brisk (the default), 50% fluid, 75% energetic.
