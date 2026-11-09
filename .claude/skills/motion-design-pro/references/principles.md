# Motion Principles

> **Sources.** Adapted from the `director/` notes of the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles), rewritten for native apps.

This is the shared vocabulary for designers and developers. Settle these questions before choosing a single duration.

## The Three Pillars

Every animation answers three questions, in order:

| Pillar | Question | It decides |
|--------|----------|------------|
| Intent | What should the person feel and understand? | Easing family, tempo, amount of bounce |
| Narrative | What is the tiny story: before, action, after? | Sequence, what leads, where it settles |
| Craft | What makes it believable? | Physics, arcs, follow-through, layering |

**Narrative scales with length.** Even a 200 ms change has a setup, an action, and a resolution:

| Total length | Anticipation | Action | Reaction | Settle |
|--------------|--------------|--------|----------|--------|
| ≤ 200 ms | none | ~65% | none | ~35% |
| 200–400 ms | 10–15% | 40–50% | 10–15% | 25–30% |
| 400–800 ms | 15–20% | 30–40% | 15–20% | 20–25% |

Leave 100–200 ms of stillness after a sequence before the next one starts. Skip anticipation for anything under ~150 ms and for hover.

## Motion Layers

| Layer | Role | Strength | Timing |
|-------|------|----------|--------|
| Primary | The action the eye follows | 100% | — |
| Secondary | Supporting reaction: shadow lifts, icon shifts, siblings make room | 30–50% of primary | 50–100 ms after |
| Ambient | Background life: a slow pulse, a gradient drift | 10–20% of primary | Continuous, slow |

A primary motion with no secondary reaction can feel flat on hero moments (onboarding, success, a card opening). In everyday productivity screens, primary alone is usually right; ambient motion is rare in apps, costs battery, and always stops under Reduce Motion.

## Motion Personality

Choose one archetype for the app and record it in `docs/design/motion.md`. It sets the defaults; specific moments may borrow from another (a calm app can celebrate a finished purchase).

| Archetype | Tempo | Curve / spring | Overshoot | Fits |
|-----------|-------|----------------|-----------|------|
| Calm / professional (default for UI) | 200–400 ms | M3 standard (0.2, 0, 0, 1); SwiftUI `.smooth` | 0–3% | Productivity, finance, health, enterprise, utilities |
| Premium | 350–600 ms | (0.4, 0, 0.2, 1); critically damped springs | 0% | Luxury, editorial, portfolio, premium subscriptions |
| Playful | 150–300 ms | Bouncy springs (SwiftUI `.bouncy`, Compose damping 0.5–0.75) | 10–20% | Kids, social, casual games, onboarding, celebrations |
| Energetic | 100–250 ms | Fast decelerate, stiff springs | 15–30% | Fitness, sports, music, games, events |

**Brand motion identity** is three constants:

1. **Signature curve or spring**, used for about 80% of animations.
2. **Duration palette**: quick / standard / slow (for example 150 / 300 / 450 ms for calm, 350 / 500 / 800 ms for premium).
3. **Entrance pattern**: one consistent way things arrive (slide up + fade, scale from 95% + fade, or bounce up).

Archetype failure modes: playful with more than ~25% overshoot looks broken, and bounce on short durations looks glitchy; premium so subtle it's invisible, or so slow people wait; professional so uniform it's monotonous; energetic at full strength everywhere, so nothing stands out.

## Emotion to Motion

| Feeling | Character | Path | Easing | Duration |
|---------|-----------|------|--------|----------|
| Confidence | Direct, decisive | Straight | Strong decelerate | 200–400 ms |
| Calm | Smooth, flowing | Gentle curves | Sine in-out | 500–1000 ms |
| Urgency | Sharp, fast | Straight | Decelerate | 100–200 ms |
| Joy | Bouncy, upward | Arcs | Spring with bounce | 200–400 ms |
| Surprise | Sudden, expanding | Outward | Exponential decelerate | 150–300 ms |
| Elegance | Slow, controlled | Long arcs | (0.4, 0, 0.2, 1) | 400–700 ms |
| Respectful departure (delete) | Quiet | Shrink in place | Accelerate | 150–250 ms |

Defaults by moment: form success = joy + confidence; validation error = mild urgency, no bounce; navigation = confidence; loading = calm; onboarding = curiosity and delight; delete = calm.

**Direction carries meaning.** Up reads as growth or arrival, down as settling or completion, forward (trailing edge → leading edge in the reading direction) as progress, backward as return, outward as importance, inward as dismissal. Mirror horizontal motion in right-to-left locales. **Color transitions go toward the state** (to green for success; flash to red for an error, then settle, never a sustained red pulse); never color alone.

## Disney's Principles, for UI

| Principle | In an app |
|-----------|-----------|
| Squash and stretch | Small (≤10%) on playful presses; never on premium or professional UI; keep volume (wider means shorter) |
| Anticipation | A 3% dip before a big expand; 100–200 ms; skip under ~150 ms |
| Staging | One hero at a time; dim or hold the rest |
| Pose to pose | UI transitions are planned keyframes; "straight ahead" is for particles and generative effects |
| Follow-through | Children trail the parent by 50–150 ms; springs give this naturally |
| Slow in, slow out | Ease everything that moves; linear only for rotation, progress, timers |
| Arcs | A slight curve feels organic; straight paths read as mechanical (fine for professional UI) |
| Secondary action | Shadows, icons, and siblings react at 30–50% strength |
| Timing | Heavier things (sheets, screens) take longer than light ones (badges, toggles) |
| Exaggeration | 0% premium, 0–5% professional, 15–25% playful |
| Solid drawing | Keep proportions and light direction consistent across keyframes |
| Appeal | Smooth, consistent, settles cleanly; nothing stops abruptly |

## Attention Budget

- **One hero motion per moment.** At most two or three elements in active motion together; ambient motion doesn't count but must stay faint.
- **The 1/3 rules**: no single movement crosses more than about a third of the screen without a change of direction or speed, and with three or more elements, no more than a third of them move at once. Screen-level navigation transitions are the exception and belong to the system.
- **Frequency lowers intensity**: something seen a hundred times a day is fast and subtle; something seen once (first launch, a milestone) can be richer. Ask whether it's still pleasant on the hundredth viewing.
- **Context lowers intensity**: busy screens, stressed people (checkout, errors, health), and task-focused flows get less motion.

## Context

| Context | Adjust |
|---------|--------|
| Phone | Baseline; one or two properties; touch feedback under 100 ms |
| iPad, Mac, Android tablet or desktop window | ~1.1–1.25× for larger travel; hover states; wider stagger fits |
| Apple Watch, Wear OS | ~0.75×; one property; no ambient |
| Apple TV, Android TV | ~1.3–1.6×; motion follows focus; system focus effects first |
| Vision Pro | Comfort first; see `apple-visionos-best-practices.md` |
| Dark appearance | Slightly less intensity; avoid bright flashes |

| Product | Personality | Density |
|---------|-------------|---------|
| Finance, health, enterprise | Calm / premium | Low |
| Social, kids, casual games | Playful | Medium–high |
| Commerce | Calm, playful on success | Medium |
| Editorial | Premium | Low |
| Fitness, games | Energetic | High |
