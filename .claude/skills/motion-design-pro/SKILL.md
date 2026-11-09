---
name: motion-design-pro
description: Designs, specs, implements, and reviews UI motion for SwiftUI and Jetpack Compose apps — purpose and emotional intent before properties, a motion personality and motion tokens (springs, curves, duration palette) in the design system, timing and easing tables, entrance/exit, feedback, loading, success/error, and choreography patterns, Reduce Motion alternatives, Lottie / dotLottie handoff, and a designer-facing motion spec. Use when adding or reviewing animations, transitions, micro-interactions, or loading and success states, when defining an app's motion language, or when turning a designer's motion prototype into code.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.0"
  grounded_in: "The LottieFiles motion design skill (lottiefiles/motion-design-skill, MIT), Apple Human Interface Guidelines (Motion), Material 3 motion guidelines, and the SwiftUI and Jetpack Compose animation documentation"
---

Make motion that explains the interface: it shows where things come from, confirms that an action worked, and makes a state change legible, and it stays fast, consistent, and comfortable. This is the deep companion to the always-on `apple-motion-design.md` and `android-motion-design.md` rules. The rules steer code while it's written; this skill designs the motion system, writes the spec designers and developers share, builds the hard sequences, and audits what exists. It serves designers (the spec and the vocabulary) and developers (the tokens and the code) from the same source.

> **Sources.** Adapted from the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles; see `NOTICE.md`): the three pillars, motion layers, personality archetypes, emotion mapping, Disney's principles for UI, timing and easing tables, patterns, and the quality checklist. Rewritten for SwiftUI and Jetpack Compose and checked against Apple's Human Interface Guidelines and Material 3 motion. Thank you to LottieFiles for publishing it openly.

Pick the mode from the request:

- **Define the motion system**: no motion tokens yet, a rebrand, or "make the app feel more X". Choose a personality with `references/principles.md`, set tokens with `references/timing-and-easing.md`, write `docs/design/motion.md` from `references/motion-spec.md`, and add the tokens to the DesignSystem / `:core:designsystem` module.
- **Spec or build an interaction**: a designer's prototype, or "animate this". Work through the checklist below, pick a recipe from `references/patterns.md`, and write the spec row before the code.
- **Review**: existing animation feels slow, cheap, robotic, distracting, or janky, or before a release. Run `references/review.md` (scan commands, quality checklist, smells and fixes).

If doing a partial task, load only the relevant reference file.

## The Checklist (before any animation)

1. **Purpose**: feedback, orientation, state change, attention, or delight. No purpose, no animation.
2. **Feeling**: the emotional target (confident, calm, urgent, joyful) within the app's personality.
3. **Primary property**: position, scale, opacity, color, or rotation, chosen from the purpose; add at most one supporting property.
4. **Duration** from the element and travel distance; entrances longer than exits.
5. **Easing direction**: decelerate in, accelerate out, ease both ends on screen, linear only for spinners and progress.
6. **Hero**: one element leads; others follow 30–60 ms apart, total under ~500 ms.
7. **Reduced alternative**: what plays under Reduce Motion / "Remove animations" (usually a crossfade, or nothing).
8. **Non-motion signal**: the text, icon, haptic, or accessibility announcement that carries the same information.

## Core Instructions

- **System components first.** Navigation, sheets, menus, M3 components, Liquid Glass, and predictive back already animate. Restyling their motion is a finding unless the design calls for it.
- **Tokens, not numbers.** Every animation in feature code references a named token. Raw durations and curves at the call site are findings, and so are two tokens that mean the same thing.
- **Consistency beats flourish.** The same interaction moves the same way everywhere; the motion personality covers about 90% of the app.
- **Comfort and access are requirements**: a reduced alternative for every spatial or looping animation, no information carried by motion alone, nothing longer than ~5 s without a pause, no blocked input.
- **Performance**: animate render-only properties (SwiftUI `opacity` / `scaleEffect` / `offset`; Compose `graphicsLayer` / lambda `offset`), keep fewer than ~20 moving elements on screen, and profile dropped frames before guessing (`instruments-profiling-pro` on Apple, the Compose layout inspector and Macrobenchmark on Android).
- **Speak both languages.** Specs use the shared vocabulary (personality, duration tokens, enter / exit / standard curves, spring bounce); implementation notes map each token to SwiftUI and Compose.
- **Severity by impact**: blocking (motion ignores Reduce Motion for large or looping movement, motion is the only signal, animation blocks input, jank on a core flow) > degraded (wrong easing direction, linear movement, durations far off the table, overshoot on errors, stagger over 500 ms, ad hoc values instead of tokens) > polish (missing follow-through or secondary motion, inconsistent entrance direction).
- Cross-reference, don't duplicate: tokens and components go to `swift-design-system-pro` / `android-design-system-pro`; SF Symbol effects to `apple-iconography.md`; VoiceOver and TalkBack details to the accessibility skills; recomposition or invalidation causes to `android-compose-pro` / `swiftui-pro`; visionOS motion comfort to `apple-visionos-best-practices.md`.

## Output Format

**Define mode:** the chosen personality and why, the token table (role · SwiftUI · Compose · when to use), the reduced-motion policy, and the `docs/design/motion.md` file.

**Spec / build mode:** the spec rows (trigger · element · property · from → to · token · delay · reduced alternative · non-motion signal), then the code for each platform in scope.

**Review mode:** findings grouped by severity. Each gives file:line, what the viewer experiences, the principle it breaks, and the fix with before/after. End with the count per severity and the first three fixes.

Example finding:

### Blocking — success animation is the only confirmation and ignores Reduce Motion

**`CheckoutView.swift:88`: the order-placed state is a looping Lottie confetti with no text and no VoiceOver announcement, and it keeps looping under Reduce Motion.**

```swift
// Before
LottieView(animation: .named("confetti")).playing(loopMode: .loop)

// After: plays once, still frame under Reduce Motion, and the text carries the meaning
VStack {
    LottieView(animation: .named("confetti"))
        .playbackMode(reduceMotion
            ? .paused(at: .progress(1))
            : .playing(.toProgress(1, loopMode: .playOnce)))
        .accessibilityHidden(true)
    Text("Order placed")
}
.sensoryFeedback(.success, trigger: orderID)
```

End of example.

## References

- `references/principles.md`: the three pillars, motion layers, personality archetypes and brand motion identity, emotion-to-motion map, Disney's principles for UI, attention budget, and context (platform, content type).
- `references/timing-and-easing.md`: duration tables, distance scaling, latency budgets, easing directions, M3 and Apple curves, springs mapped across SwiftUI and Compose, overshoot and stagger budgets.
- `references/patterns.md`: entrance and exit, press, hover and focus, toggle, success, error, loading, ambient, and multi-element recipes, with SwiftUI and Compose sketches.
- `references/motion-spec.md`: the designer–developer contract: the `docs/design/motion.md` template, token files for both platforms, and Lottie / dotLottie handoff rules.
- `references/review.md`: scan commands, the quality checklist, motion smells and their fixes.
