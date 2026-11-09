# Timing and Easing

> **Sources.** Tables adapted from `reference/timing-easing-tables.md` in the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles), tuned to phone baselines and mapped to SwiftUI and Compose using Apple's and Material 3's published motion values.

## Duration by Element (phone baseline)

| Element | Duration | Why |
|---------|----------|-----|
| Tooltip, ripple, micro-feedback | 80–120 ms | Must feel instant |
| Button press, toggle, checkbox | 100–150 ms | Responsive |
| Icon or symbol change | 150–250 ms | Readable state change |
| Card, row, chip enter / exit | 200–300 ms | Spatial awareness |
| Custom sheet, dialog, popover | 250–350 ms | Focus shift |
| Screen-level transition you build | 300–450 ms | Context switch (prefer the system's) |
| Hero reveal, onboarding moment | 500–1000 ms | Seen rarely |
| Ambient loop cycle | 2–20 s | Should be barely noticed |

- **Distance scales duration**: ~100 pt / dp of travel is the base; 200 is ~1.3×, 400 ~1.6×, the full screen ~1.8–2×.
- **Weight scales duration**: heavy (sheets, overlays) long and without bounce; medium (cards) moderate with a 3–5% settle; light (badges, icons) quick and may bounce a little.
- **Entrances take longer than exits**: an exit is ~65–75% of its entrance. People care about what's arriving.

## Response Budgets

| Interaction | Visible response within |
|-------------|-------------------------|
| Drag start | 50 ms |
| Hover in | 100 ms (hover out 150–200 ms) |
| Press | 150 ms |
| Release and settle | 200–300 ms |
| Error shake | 300–400 ms total |
| Long press trigger | 500–800 ms |

## Easing Direction

| Situation | Easing | SwiftUI | Compose |
|-----------|--------|---------|---------|
| Entering | Decelerate | `.easeOut`, springs | `EmphasizedDecelerate` / spatial spring |
| Leaving | Accelerate | `.easeIn` | `EmphasizedAccelerate` |
| Moving on screen | Ease in-out | `.smooth`, `.easeInOut` | `Standard` / `defaultSpatialSpec()` |
| Looping (pulse, float) | Sine in-out | `.easeInOut.repeatForever(autoreverses: true)` | `infiniteRepeatable(tween(easing = FastOutSlowInEasing), RepeatMode.Reverse)` |
| Rotation, progress, timers | Linear | `.linear` | `LinearEasing` |

Never linear for spatial movement; it reads as robotic.

## Named Curves

| Curve | Cubic Bézier | Use |
|-------|-------------|-----|
| M3 standard | (0.2, 0, 0, 1) | Default on-screen movement |
| M3 standard decelerate | (0, 0, 0, 1) | Simple entrances |
| M3 standard accelerate | (0.3, 0, 1, 1) | Simple exits |
| M3 emphasized decelerate | (0.05, 0.7, 0.1, 1) | Hero entrances |
| M3 emphasized accelerate | (0.3, 0, 0.8, 0.15) | Hero exits |
| Classic ease (`FastOutSlowIn`) | (0.4, 0, 0.2, 1) | Premium, smooth |
| Back-out (overshoot) | (0.175, 0.885, 0.32, 1.275) | Playful landings; prefer a spring |

SwiftUI: `.timingCurve(0.2, 0, 0, 1, duration: 0.3)`. Compose: `CubicBezierEasing(0.2f, 0f, 0f, 1f)`.

M3 duration tokens: short 50 / 100 / 150 / 200 ms, medium 250 / 300 / 350 / 400 ms, long 450 / 500 / 550 / 600 ms, extra long 700 / 800 / 900 / 1000 ms.

## Springs Across Platforms

Springs keep their velocity when interrupted, so prefer them for anything a gesture can catch. Think in two numbers: how long it takes to settle, and how much it bounces.

| Feel | SwiftUI | Compose |
|------|---------|---------|
| No bounce, smooth | `.smooth(duration:)` (bounce 0) | `spring(dampingRatio = 1f, stiffness = StiffnessMediumLow)` |
| Crisp, a hint of bounce | `.snappy(duration:)` | `spring(dampingRatio = 0.85f, stiffness = StiffnessMedium)` |
| Visible bounce | `.bouncy(duration:)` | `spring(dampingRatio = DampingRatioLowBouncy)` (0.75) |
| Celebration | `.spring(duration: 0.5, bounce: 0.4)` | `spring(dampingRatio = DampingRatioMediumBouncy)` (0.5) |
| Theme-driven | your `Motion` tokens | `MaterialTheme.motionScheme.fast / default / slowSpatialSpec()` |

Rough conversion: SwiftUI `bounce` ≈ 1 − Compose `dampingRatio` for values between 0 and ~0.5. A damping ratio below 1 oscillates, 1 settles fastest without oscillating, above 1 settles slowly.

**Material behaves like this**: rigid things (metal, glass) don't bounce and run a touch slower; elastic things bounce 15–25% and run faster; paper-like cards settle with 3–5%; fluid and gas-like effects are slow and soft.

## Overshoot Budget

| Context | Overshoot |
|---------|-----------|
| Error, destructive, premium | 0% |
| Ordinary feedback | 2–5% |
| Success | 5–10% |
| Celebration | 15–25% |

Never overshoot color or opacity (Compose effects specs exist for this reason).

## Stagger

| Pattern | Gap | Total | Use |
|---------|-----|-------|-----|
| Micro cascade | 20–40 ms | < 200 ms | List rows, grid cells |
| Standard | 40–80 ms | < 400 ms | Cards, panels, nav items |
| Dramatic | 100–150 ms | < 600 ms | A rare hero section |

Keep the total under ~500 ms: cap the number of staggered items (animate the first screenful, show the rest immediately). Order follows reading order, or radiates from the element that triggered it; exits run in reverse. All staggered items share one curve; only the start time varies.

## Personality Palettes

| Tier | Calm | Premium | Playful | Energetic |
|------|------|---------|---------|-----------|
| Quick | 150 ms | 350 ms | 150 ms | 100 ms |
| Standard | 300 ms | 500 ms | 250 ms | 180 ms |
| Slow | 450 ms | 800 ms | 400 ms | 300 ms |
