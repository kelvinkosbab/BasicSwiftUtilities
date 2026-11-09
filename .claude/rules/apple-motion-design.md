---
description: Motion design for SwiftUI apps — purpose before properties, motion tokens in the DesignSystem module (springs and curves by role, a duration palette), entrance vs. exit timing, no linear spatial motion, render-only animatable properties, one hero per moment, Reduce Motion alternatives for every spatial or looping animation, haptics paired with feedback, and Lottie playback rules
globs: "**/*.swift"
paths:
  - "**/*.swift"
must:
  - "Animate from named motion tokens in the DesignSystem module, never ad hoc durations or curves at the call site."
  - "Every spatial, scaling, or looping animation has a Reduce Motion alternative (a crossfade or no animation)."
  - "Never use linear timing for movement; linear is only for spinners, progress, and timers."
  - "Motion never carries information alone and never blocks input while it plays."
---

# Apple Motion Design

Motion is part of the interface, not decoration. A good animation answers one question (where did this come from, did my tap work, what changed) and gets out of the way; a bad one makes the app feel slow, hides state, or makes people feel sick. Standard SwiftUI and UIKit components already animate correctly (navigation pushes, sheets, menus, toggles, Liquid Glass): don't re-animate them. This rule covers the custom moments. The cross-platform `motion-design-pro` skill designs a motion system, specs interactions with designers, and reviews existing animation.

> **Sources.** Motion principles, timing tables, and patterns adapted from the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles), rewritten for SwiftUI and combined with Apple's Human Interface Guidelines (Motion) and SwiftUI animation documentation.

## Decide Before You Animate

- **Name the purpose first**: feedback (the tap worked), orientation (where content came from or went), state change (what changed), attention (look here, rarely), or delight (a reward, rarer still). No purpose, no animation.
- **Pick the primary property from the purpose**: position for arriving and leaving, scale for press and emphasis, opacity combined with one of those for appearing, color for state, rotation only for progress or a playful accent. One property is direct, two is polished, three is usually too many.
- **The app has one motion personality** (see `motion-design-pro` → `principles.md`): calm and professional for most utility apps, smooth with no overshoot for premium brands, springy for playful ones. Pick it once in the design system and use it everywhere; borrow a livelier curve only for a specific moment such as success.
- **The same interaction animates the same way every time.** Consistency is what makes motion feel intentional.

## Motion Tokens

- **Tokens live in the `DesignSystem` module** (see [`apple-design-system.md`](./apple-design-system.md)) and are named by role, not by number:

```swift
public enum Motion {
    /// Press, toggle, small state flips.
    public static let feedback = Animation.snappy(duration: 0.15)
    /// Default for on-screen changes.
    public static let standard = Animation.smooth(duration: 0.3)
    /// Arrivals that should land with a little life (cards, sheets you build yourself).
    public static let enter = Animation.spring(duration: 0.35, bounce: 0.1)
    /// Departures are quicker and accelerate away.
    public static let exit = Animation.easeIn(duration: 0.2)
    /// Celebrations only.
    public static let celebrate = Animation.bouncy(duration: 0.4)
}
```

- **Prefer springs** (`.smooth`, `.snappy`, `.bouncy`, `.spring(duration:bounce:)`): they keep velocity when interrupted, which curves can't. Use curves (`.easeIn`, `.easeOut`, `.timingCurve`) for exits and fixed-length sequences.
- **Bounce budget**: 0 for errors, destructive actions, and premium brands; 0.1–0.15 for feedback; up to 0.3 for celebrations. Overshoot on an error reads as a joke.
- **Timing by element** (phone baseline): press/toggle 0.1–0.15 s, icon change 0.15–0.25 s, card or row 0.2–0.3 s, custom sheet or dialog 0.25–0.35 s, screen-level transition 0.3–0.45 s. Larger travel takes a little longer (iPad and Mac ≈1.1–1.25×); watchOS is shorter and simpler; tvOS is slower and driven by the focus engine.
- **Exits are faster than entrances** (about 65–75% of the entrance duration), and decelerate into place on entry, accelerate on exit.

## Writing Animations

- **Always scope animations to a value**: `.animation(Motion.standard, value: isExpanded)` or `withAnimation(Motion.feedback) { … }`. Never the value-less `.animation(_:)` (deprecated; it animates everything).
- **Animate render-only properties**: `opacity`, `scaleEffect`, `offset`, `rotationEffect`, and `visualEffect` don't re-run layout. Animating `frame`, `padding`, or a font size relayouts every frame; fine for one container, a dropped-frame source in lists.
- **Transitions combine movement with opacity**: `.transition(.move(edge: .bottom).combined(with: .opacity))`, `.asymmetric(insertion:removal:)` when entry and exit differ, `.blurReplace` and `.push(from:)` for in-place swaps.
- **Use the purpose-built APIs**: `.contentTransition(.numericText(value:))` for changing numbers, `.symbolEffect` for SF Symbols (see [`apple-iconography.md`](./apple-iconography.md)), `matchedGeometryEffect` and `.navigationTransition(.zoom(sourceID:in:))` with `.matchedTransitionSource` for continuity, `PhaseAnimator` for multi-step sequences, `KeyframeAnimator` for choreographed properties, `.scrollTransition` for scroll-linked effects.
- **One hero per moment**: with several elements, stagger them (30–60 ms apart, total under ~500 ms) in reading order, from the trigger's side. Don't move more than about a third of the screen's elements at once.
- **Never block input** while an animation plays, and let a new gesture interrupt the old animation (springs do this for free).
- **Pair feedback with haptics where the system would**: `.sensoryFeedback(.success, trigger:)`, `.impact`, `.selection`. Haptics never replace a visible state change.

## Reduce Motion and Comfort

- **Read `@Environment(\.accessibilityReduceMotion)`** and swap spatial motion for a crossfade or no animation. Keep the opacity change; drop the slide, zoom, bounce, parallax, and spin:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

content
    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
    .animation(reduceMotion ? .easeInOut(duration: 0.15) : Motion.enter, value: isShown)
```

- **Loops stop under Reduce Motion**: pulses, shimmer, floating, and auto-playing Lottie show a still frame. Any animation longer than about 5 seconds needs a way to pause it.
- **Motion never carries information alone**: an error shake comes with red text and an icon; a success pop comes with a checkmark and text. VoiceOver users see none of it, so post the state change too (see [`apple-accessibility-best-practices.md`](./apple-accessibility-best-practices.md)).
- **Avoid vestibular triggers**: large zooms, full-screen slides that aren't navigation, spinning large elements, multi-layer parallax, fast direction changes. visionOS has stricter rules (see `apple-visionos-best-practices.md` when installed).

## Lottie and Designer-Made Animations

- **Load Lottie through `lottie-ios`'s `LottieView`**; prefer `.lottie` (dotLottie) files for size. Wrap it in a DesignSystem component so playback, theming, and Reduce Motion are handled once.
- **Play once for feedback** (`.playing(loopMode: .playOnce)`), loop only for loading or ambient states, and show a still frame (the final frame for success, a neutral frame otherwise) under Reduce Motion. Recent `lottie-ios` versions follow the system setting through their reduced-motion configuration; confirm the version you pin does.
- **Decorative animations are hidden from VoiceOver** (`.accessibilityHidden(true)`); meaningful ones get a label that states the result ("Payment complete").
- **Theme colors in code** with value providers on named layers, so dark mode and brand changes don't need a new export.
