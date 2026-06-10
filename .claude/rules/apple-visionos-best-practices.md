---
description: Patterns for visionOS apps — scene types, immersion styles, spatial gestures, RealityKit / ECS conventions, head-mounted-display accessibility, USDZ pipeline, performance budgets
globs: "**/*.swift"
---

# visionOS Best Practices

Spatial apps fail in different ways than 2D apps. A `WindowGroup` that ships fine on iPad can be unusable in mixed reality; a 60fps animation that looks great on a phone causes nausea on a head-mounted display; a confidently-coded immersive experience that lacks a clear exit traps the user. These rules pin the conventions that catch those failure modes early.

This rule **complements** the Apple bundle's other rules — visionOS still uses Swift 6 strict concurrency, the same SwiftUI MVVM pattern, the same accessibility primitives, the same DocC/testing/localization patterns. Reach for those rules first; this one only covers the spatial-specific overlay.

## Scene Types

visionOS has three scene types and they're not interchangeable. Pick deliberately.

- **`WindowGroup`** — flat 2D content rendered as a virtual surface in the user's space. The default for most apps. Multiple windows can coexist; users place them where they want.
- **`Volume` (via `WindowGroup` with `.windowStyle(.volumetric)`)** — bounded 3D content with finite dimensions. Good for a single 3D object (a model viewer, a game piece, a chess board). The user can rotate the whole volume in place.
- **`ImmersiveSpace`** — unbounded 3D content. Replaces or overlays the user's view of the room. Only **one** ImmersiveSpace can be open at a time across the entire system. Don't reach for this unless your content genuinely fills the user's space.

## Opening and Dismissing Spaces

Use the environment values, not custom plumbing:

```swift
@Environment(\.openImmersiveSpace)   private var openImmersiveSpace
@Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
@Environment(\.scenePhase)            private var scenePhase

// Open from a button or onAppear:
Task {
    let result = await openImmersiveSpace(id: "ConcertHall")
    switch result {
    case .opened:           // success
    case .userCancelled:    // user dismissed the system prompt
    case .error:            // failed for other reasons — handle gracefully
    @unknown default:       break
    }
}
```

- **Always check the `OpenImmersiveSpaceAction.Result`.** Don't assume `.opened` — the user can cancel the consent dialog.
- **Provide a visible exit** for every ImmersiveSpace. A floating dismiss button is the minimum. Never trap the user.
- **Tear down on `scenePhase` background.** When the app loses scene phase, dismiss any open ImmersiveSpace so resources don't leak.

## Immersion Styles

`ImmersiveSpace` takes an `.immersionStyle(selection:in:)` modifier with three real options:

- **`.mixed`** — passthrough remains visible; your content is anchored in the user's real environment. Use for productivity, AR overlays, anything contextual.
- **`.progressive`** — user can dial the immersion level with the Digital Crown. Use when content benefits from optional environmental separation (a movie, a focused workspace).
- **`.full`** — total visual replacement. Use only when the content is the whole point (a game, a meditation app, a virtual environment). Requires explicit, easy escape.

**Default to `.mixed`.** Going full-immersion without good reason is the visionOS equivalent of modal-dialog overuse — it signals the developer didn't think about coexistence with the user's environment.

```swift
ImmersiveSpace(id: "MyContent") {
    MyImmersiveView()
}
.immersionStyle(selection: $style, in: .mixed, .progressive, .full)
```

## Spatial Gestures

Standard SwiftUI gestures (`TapGesture`, `DragGesture`, `MagnifyGesture`, `RotateGesture`) all work, but the spatial variants exist for a reason:

- **`SpatialTapGesture`** — knows the 3D hit location, not just whether a hit happened.
- **`RotateGesture3D`** — captures axis + angle, not just 2D rotation.
- **`.targetedToEntity()` / `.targetedToAnyEntity()`** — bind a gesture to a RealityKit `Entity` so you get the hit Entity in the gesture closure.

```swift
RealityView { content in
    let model = try? await Entity(named: "ChessKnight", in: realityKitContentBundle)
    if let model { content.add(model) }
}
.gesture(
    SpatialTapGesture()
        .targetedToAnyEntity()
        .onEnded { value in
            let entity = value.entity   // the actual Entity that was hit
            // …
        }
)
```

**Every interactable entity needs a hover affordance.** Without one, users have no feedback before commit — the visionOS equivalent of a button with no `:hover` state:

```swift
// On the Entity (RealityKit):
entity.components.set(HoverEffectComponent())   // default highlight
entity.components.set(InputTargetComponent())   // required for gesture targeting
entity.components.set(CollisionComponent(shapes: [.generateBox(size: ...)]))

// Or on a SwiftUI view:
SomeView()
    .hoverEffect(.highlight)
```

## Accessibility (Critical on a Head-Mounted Display)

Accessibility on visionOS is **not optional cosmetic polish** — it's safety. People can get motion sick from spatial apps that ignore these rules.

- **`@Environment(\.accessibilityReduceMotion)` is vestibular safety.** Honor it for *all* motion — camera moves, content drift, large transforms, particle systems. Don't just disable cosmetic animation; disable anything that moves the user's perceived viewpoint.

  ```swift
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func animateCameraMove() {
      withAnimation(reduceMotion ? .none : .smooth(duration: 0.8)) { ... }
  }
  ```

- **VoiceOver works in 3D.** Every interactive Entity needs `.accessibilityLabel(_:)` and an appropriate role. Treat 3D widgets like UIControls.
- **Don't override the system focus indicator.** The user's gaze is the system cursor — never replace or hide its visual feedback in ImmersiveSpaces.
- **Provide a clear exit from any immersive state.** A dismiss button rendered as 3D geometry inside the immersive view, or always-accessible system back gesture support. Trapping the user is a serious a11y failure.
- **Don't lock content to `.head` anchor for things the user reads.** Head-locked text causes vertigo. World-locked text (anchored to a `.plane` or in a Volume) is fine.
- **`accessibilityRespondsToUserInteraction(_:)`** for custom 3D controls that aren't standard SwiftUI controls — tells VoiceOver they're actionable.

## RealityKit and ECS Patterns

- **Author content in Reality Composer Pro, not code.** Materials, scenes, animations, particle systems should live in a `.rkassets` package edited visually. Loading them in Swift via `Entity(named:in:)` is the well-supported path.
- **Keep Entity hierarchies shallow.** Deep parent-child trees stress the ECS system and the renderer. If you're nesting more than 3-4 levels, you're probably building UI in 3D where SwiftUI would do better.
- **Anchor strategy matters:**
  - **`.head`** — only for true HUD overlays (a heart-rate readout, system status). Anything text-heavy here is a motion-sickness vector.
  - **`.plane`** — world-locked content (a virtual chessboard on the real table). The default for most spatial content.
  - **`.image`** — image-recognition-locked content (an AR overlay on a poster). Use sparingly; image tracking is fragile.
  - **`.hand`** — hand-anchored UI (a wrist menu). Reserve for ergonomically-justified UI.
- **Cache Entity references, don't re-look-up.** `Entity.findEntity(named:)` walks the hierarchy. Cache results on first access:

  ```swift
  @State private var heroEntity: Entity?

  RealityView { content in
      let root = try await Entity(named: "Scene", in: realityKitContentBundle)
      content.add(root)
      heroEntity = root.findEntity(named: "Hero")
  } update: { content in
      // use heroEntity directly — no findEntity in the update closure
  }
  ```

- **Materials**: prefer `PhysicallyBasedMaterial` for content that should match real-world surfaces. Use `UnlitMaterial` for UI overlays where lighting is a distraction.
- **Don't `addChild(_:)` from every frame.** Set up hierarchies once; use Components to drive per-frame behavior. RealityKit's update model is component-based, not parent-child.

## Performance Budgets

- **Target 90fps. Not 60.** Frame drops on a head-mounted display cause physical discomfort — users feel them, not just see them.
- **Use the visionOS Performance HUD** during development (`MetalCaptureManager` / instruments). Frame time over 11.1ms is a problem; over 16.6ms is a serious problem.
- **Particle counts**: under 1000 active emitted at once for entities at typical viewing distance. Above that, switch to billboarded sprites or shader-based effects.
- **Triangle counts**: aim for under ~100k triangles per Entity at typical (1-2m) viewing distance. RealityKit doesn't auto-LOD; you author LOD via multiple meshes if needed.
- **Lighting**: prefer Image-Based Lighting (IBL) over real-time lights when you can. Realtime point lights are expensive; use them deliberately.
- **Shadows**: dynamic shadow casting is expensive. Bake when possible.
- **Texture sizes**: 2048² is the common ceiling for most entities. 4096² only for surfaces the user gets very close to.

## USDZ / Asset Pipeline

- **Reality Composer Pro is the authoring tool.** Hand-editing `.usda` is feasible for trivial scenes but the workflow is much smoother in RCP — and the integration with RealityKit Components is built in.
- **Ship `.usdz`** (zipped binary). Source-control `.usda` (text). Reality Composer Pro saves a `.rkassets` package that holds both.
- **Bundle resources** via a Swift package or app target. Load via the generated module accessor:

  ```swift
  import RealityKitContent   // generated module for your .rkassets package

  let entity = try await Entity(named: "Hero", in: realityKitContentBundle)
  ```

- **`Entity(named:in:)` is async-throwing.** Handle the failure case — bundle load errors are real (corrupt asset, wrong bundle).
- **Don't ship unused assets.** `.usdz` files are expensive to load and consume memory. Strip anything not referenced from your scenes.

## Window vs Volume vs ImmersiveSpace Coexistence

- **A volumetric window and a window can be open at the same time.** Two windows can be open. But only one ImmersiveSpace.
- **When opening an ImmersiveSpace, system windows behind it dim automatically** (`.mixed` and `.progressive` styles). Don't manually dim — the system handles it.
- **Closing the last visible window does NOT terminate an ImmersiveSpace.** Track scene state explicitly if you need that.

## What to Avoid

- **Head-locked text** for content the user reads — vertigo vector.
- **Continuous camera motion** in `.full` immersion — nausea vector. Use teleport-style discrete movement instead.
- **Tiny tap targets in 3D space** — eye-tracking precision is ~0.5° of visual arc; targets smaller than ~30pt at 1m viewing distance are unreliable.
- **Bright flashes or strobe-like animation** — accessibility hazard and a battery drain.
- **Unbounded ImmersiveSpace from app launch** — feels invasive. Open it from a deliberate user action.
- **Replacing system gestures or focus.** Long-press, eye gaze, pinch — these are platform conventions; users learn them once and expect them everywhere.

## Patterns to Follow

```swift
// Scene composition — Window for control, Volume for the model, ImmersiveSpace for the full experience.
@main
struct MyApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        WindowGroup(id: "Controls") {
            ControlsView()
        }

        WindowGroup(id: "Preview") {
            ModelPreviewView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)

        ImmersiveSpace(id: "Stage") {
            StageImmersiveView()
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}

// Opening an ImmersiveSpace defensively
struct ControlsView: View {
    @Environment(\.openImmersiveSpace)   private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isStageOpen = false

    var body: some View {
        Button(isStageOpen ? "Close Stage" : "Open Stage") {
            Task {
                if isStageOpen {
                    await dismissImmersiveSpace()
                    isStageOpen = false
                } else {
                    switch await openImmersiveSpace(id: "Stage") {
                    case .opened:        isStageOpen = true
                    case .userCancelled: break          // user said no — respect that
                    case .error:         isStageOpen = false   // surface to UI
                    @unknown default:    break
                    }
                }
            }
        }
    }
}

// Interactable Entity with hover + tap, reducing motion respected
struct StageImmersiveView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RealityView { content in
            let root = try? await Entity(named: "Stage", in: realityKitContentBundle)
            guard let root else { return }
            for entity in root.children where entity.components.has(InputTargetComponent.self) {
                entity.components.set(HoverEffectComponent())
            }
            content.add(root)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let entity = value.entity
                    let duration: TimeInterval = reduceMotion ? 0 : 0.4
                    entity.move(
                        to: entity.transform.translation + SIMD3(0, 0.1, 0),
                        relativeTo: entity.parent,
                        duration: duration
                    )
                }
        )
    }
}
```
