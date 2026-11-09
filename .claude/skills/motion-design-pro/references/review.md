# Reviewing Motion

> **Sources.** The checklist, severity tiers, and smells are adapted from `reference/quality-checklist.md` and `reference/troubleshooting.md` in the LottieFiles [motion design skill](https://github.com/lottiefiles/motion-design-skill) (MIT, © 2025 LottieFiles); the scan commands and platform checks are AppBootstrapAI's.

## 1. Inventory

Find every custom animation, then judge each one in context. Search, don't assume:

```bash
# SwiftUI / UIKit
rg -n --type swift 'withAnimation|\.animation\(|\.transition\(|matchedGeometryEffect|PhaseAnimator|phaseAnimator|keyframeAnimator|repeatForever|UIView\.animate|CABasicAnimation|LottieView'
rg -n --type swift '\.animation\([^,]*\)\s*$'            # value-less .animation(_:) (deprecated)
rg -n --type swift '\.linear(\(|\b)'                       # linear: OK only for rotation/progress
rg -n --type swift '(duration|delay):\s*[0-9.]+' | rg -v 'DesignSystem|Motion'   # ad hoc numbers
rg -l --type swift 'repeatForever|loopMode: \.loop' | xargs rg -L 'accessibilityReduceMotion|reduceMotion'

# Compose
rg -n --type kotlin 'animate\w*AsState|updateTransition|AnimatedVisibility|AnimatedContent|Crossfade|animateContentSize|rememberInfiniteTransition|Animatable\(|LottieAnimation|sharedElement'
rg -n --type kotlin 'LinearEasing'
rg -n --type kotlin 'tween\(\s*(durationMillis\s*=\s*)?[0-9]+' | rg -v 'designsystem|AppMotion'
rg -l --type kotlin 'rememberInfiniteTransition|IterateForever|infiniteRepeatable' | xargs rg -L 'ANIMATOR_DURATION_SCALE|areAnimatorsEnabled|ReducedMotion|reduceMotion'
```

`install.sh audit --topic motion` runs the looping-without-reduced-motion check for you.

Then run the app: with Reduce Motion on (iOS Settings → Accessibility → Motion; Android Developer options animator scale 0, or Accessibility → Remove animations), with slow animations (Simulator Debug → Slow Animations; animator duration scale 5×), and on a low-end device.

## 2. Quality Checklist

**Purpose and feel**
- [ ] Each animation has a stated purpose; decorative motion is rare and earns its place.
- [ ] The motion personality is consistent; exceptions are deliberate.
- [ ] Intensity matches importance and frequency; still pleasant on the hundredth viewing.
- [ ] Same interaction, same motion, everywhere.

**Technique**
- [ ] No linear timing on movement.
- [ ] Decelerate in, accelerate out, ease in-out on screen.
- [ ] Durations within the element table, scaled for distance; exits shorter than entrances.
- [ ] Values come from tokens.
- [ ] Stagger total under ~500 ms; one hero per moment; no more than a third of elements moving at once.
- [ ] No overshoot on errors, destructive actions, color, or opacity.
- [ ] Follow-through: children settle 50–150 ms after parents on hero moments.
- [ ] System components keep their own motion.

**Access and comfort**
- [ ] Reduce Motion / "Remove animations" gives a crossfade or nothing for every spatial, scaling, or looping animation.
- [ ] Motion never carries information alone: text, icon, haptic, and an accessibility announcement or semantics carry it too.
- [ ] Nothing longer than ~5 s plays without a pause control; no auto-playing loops under reduced motion.
- [ ] No large zooms, spinning large elements, multi-layer parallax, or rapid direction changes.
- [ ] Input is never blocked waiting for an animation; gestures can interrupt.

**Performance**
- [ ] Animated properties are render-only (opacity, scale, offset, rotation; `graphicsLayer` in Compose).
- [ ] Fewer than ~20 animated elements on screen; loops pause off screen and in the background.
- [ ] Holds frame rate on a low-end device (Instruments Animation Hitches / `instruments-profiling-pro`; Macrobenchmark `FrameTimingMetric` or JankStats on Android).
- [ ] Lottie files are within budget and render correctly on both platforms.

## 3. Severity

| Severity | Examples |
|----------|----------|
| Blocking | Large or looping motion ignores Reduce Motion; motion is the only signal of success or failure; animation blocks input; jank on a core flow; a vestibular trigger with no alternative |
| Degraded | Linear movement; wrong easing direction; durations far off the table; ad hoc values; stagger over 500 ms; overshoot on an error; system component motion overridden; inconsistent personality |
| Polish | No secondary reaction on a hero moment; no follow-through; inconsistent entrance direction; missing counter-motion |

## 4. Smells and Fixes

| It feels… | Likely cause | Fix |
|-----------|--------------|-----|
| Robotic | Linear timing, straight paths, everything synced | Ease it; a slight arc; offset starts by 50–150 ms |
| Slow | Duration above the table; ease in-out where ease-out works; long anticipation; stagger too long; slow spring settle | Shorten; decelerate entrances; drop anticipation; cap stagger; raise damping |
| Jarring | Too short for its size; no easing; no settle; big motion with no wind-up | Lengthen to the table; ease; add 50–100 ms settle |
| Cheap or flat | Opacity only; one curve for everything; no follow-through | Pair opacity with movement or scale; vary primary vs. secondary; trail children |
| Distracting | Too many moving things; amplitude too big; ambient too strong; competing heroes | 1/3 rule; shrink amplitude; slow and fade ambient; one hero |
| Generic | Default curves everywhere | Apply the personality's signature curve and duration palette |
| Inconsistent | Same interaction animated differently; entry direction changes | Standardize per interaction via tokens; one origin |
| Janky | Layout properties animated; too many layers; heavy shadows or blur; everything at once | Render-only properties; fewer elements; pre-render effects; stagger to spread work |
