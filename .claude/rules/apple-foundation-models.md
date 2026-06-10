---
description: Enforce patterns for Apple Foundation Models (on-device LLM) integration — session lifecycle, availability gating, streaming, testability
globs: "**/*.swift"
---

# Apple Foundation Models

Rules for code that `import FoundationModels` (iOS 26+ / macOS 26+). Foundation Models started as on-device-only via Apple Intelligence; as of the 2026 SDKs (Xcode 27) it's a single Swift API spanning **on-device, Private Cloud Compute, and external/custom model providers**, with image input. It can be unavailable, slow to warm up, and it streams. Treat it like a network call with a local cache, not a synchronous function.

> **Beta surface.** The pluggable-model and image-input APIs below are **Beta** in the 2026 SDKs. Symbol names are from Apple's current Foundation Models DocC; **verify against the iOS 27 SDK** before hardcoding — beta symbols shift between seeds. The lifecycle / streaming / error-handling patterns (which predate 2026) are stable.

## Session Ownership

- **Sessions live in `@MainActor @Observable final class`** — never in a `struct`, `View`, or a background actor. SwiftUI binds to streamed updates, which must run on the main thread.
- **Keep one `LanguageModelSession` alive per conversational context.** Multi-turn history is embedded in the session; throwing it away per prompt loses context and wastes warmup.
- **Only recreate a session when its configuration actually changes** (system instructions, tools, `responseLength`). Document that history is lost on recreation so callers know.
- **Hold the session as `private var session: LanguageModelSession?`**, initialized lazily. Don't force-unwrap it — check for `nil` and rebuild if needed.

## Availability Gating (Two Levels)

- **Device eligibility first:** switch on `SystemLanguageModel.default.availability`. Handle each `.unavailable(_)` reason distinctly — `.deviceNotEligible` should *hide* AI UI entirely, `.appleIntelligenceNotEnabled` should show a "turn on in Settings" affordance.
- **Then user-level gating:** wrap the check in a feature-flag or preference (`@AppStorage("aiFeaturesEnabled")`) so users can disable AI even on capable devices.
- **Surface availability via `@Observable`**, not via polling. Make a single `AppleIntelligenceSupport` utility (or equivalent) that exposes `isAvailable: Bool` and `unavailabilityReason: String?` for the UI to bind to.
- **Never call `LanguageModelSession(...)` without checking availability first** — initialization can throw or silently produce a session that immediately fails.

## Choosing a Model: On-Device / Private Cloud Compute / External (Xcode 27, Beta)

Foundation Models is no longer on-device-only. A `LanguageModelSession` can run against any model conforming to the `LanguageModel` protocol:

- **`SystemLanguageModel`** — the on-device Apple model (the default; gate via `.availability` as above). Lowest latency, no network, free.
- **`PrivateCloudComputeLanguageModel`** — Apple's larger server models over Private Cloud Compute: more capable, needs network, keeps Apple's privacy guarantees. App Store Small Business Program members under the download threshold get it at no cloud-API cost; budget for it otherwise. Treat it as a network call — handle offline / latency / failure.
- **External providers (Claude, Gemini, self-hosted)** — bridge them by implementing the `LanguageModelExecutor` protocol (handling a `LanguageModelExecutorGenerationRequest`, streaming deltas back through a `LanguageModelExecutorGenerationChannel`, and advertising `LanguageModelCapabilities`). The rest of your code keeps talking to `LanguageModelSession` and stays provider-agnostic.

Guidance:

- **Pick per use-case, not globally.** On-device for cheap / private / offline turns; PCC or an external model for harder reasoning. Type the holder's dependency as `any LanguageModel` so you can switch without touching call sites.
- **Availability gating applies per model.** On-device → `SystemLanguageModel.default.availability`; PCC / external → reachability plus your own credential / quota checks. Expose a single `isAvailable` for the *currently selected* model.
- **Don't leak provider choice into the View.** Model selection lives in the `@MainActor @Observable` session holder; the View just sends prompts.
- **An external or PCC model means data leaves the device.** Get user consent and don't send more context than the task needs — same posture as any network upload.
- **Profile with the Foundation Models Instrument** (new in Xcode 27) — it traces instructions, prompts, responses, token usage, and inference latency. Use it to catch context-window bloat and slow turns before users do, and to compare on-device vs. PCC cost.

## Multimodal Input (Images, Beta)

The 2026 betas add image input. Build a `Prompt` with an `Attachment` whose content is an `ImageAttachmentContent` (conforming to `AttachmentContent`); images already in the conversation surface as `ImageReference` in the `Transcript`.

- **Gate on capability, not OS version.** Not every model accepts images — check the model's `LanguageModelCapabilities` before attaching and fall back to text-only when it can't.
- **Downsize before attaching.** Full-resolution photos blow the context budget and slow inference; resize / compress to what the task actually needs.
- **Treat attached images as data that leaves the device** for PCC / external models (see consent note above).

## Streaming Responses

- **Append a placeholder message *before* starting the stream**, then mutate it in place as tokens arrive. Users see the assistant "typing" immediately instead of a frozen UI.
- **On error, remove the placeholder** so the transcript doesn't show an empty assistant bubble.
- **Check `Task.isCancelled` inside the streaming loop.** Without it, navigating away leaves the model generating into the void and blocks the session for the next turn.
- **Use `defer { isGenerating = false }` at the top of the streaming function.** Guarantees the send button re-enables on early return, error, or cancellation — not just the happy path.
- **Do not force-unwrap stream elements or the session.** Network-like code needs `guard let` / `try?` discipline.

## Error Handling

- **Catch broadly and surface `error.localizedDescription`** for display. Foundation Models' error enum (`LanguageModelError`) is young and still **Beta** in the 2026 SDKs; pattern-matching specific cases (`unavailable`, `exceededContextWindowSize`) will break between seeds and across OS releases. Xcode 27 keeping it Beta is exactly why this rule exists.
- **Localize user-facing error strings yourself** when you add context ("Couldn't reach on-device model: \(reason)"). The raw `localizedDescription` is not always user-friendly.
- **Log the full error** (type + description) via your `Loggable` implementation for diagnostics, even when you show a simplified message to the user.

## Testability — Protocol + Mock + Simulator

- **Define a protocol** (`ChatSessionProtocol`, `ExplainerProtocol`) that wraps the Foundation Models API. Production views must not import `FoundationModels` directly — they depend on the protocol.
- **Ship three implementations:**
  - **Real** — the `FoundationModels`-backed type, gated behind `#if canImport(FoundationModels)` and `@available(iOS 26, *)`.
  - **Mock** — deterministic responses for unit tests.
  - **Simulator** — streams lorem ipsum (or canned content) word-by-word on a timer, so the simulator (which lacks Apple Intelligence) can demo the real streaming UI.
- **Inject via `@Environment`**, with `nil` defaults and lazy local fallback in the view: `@State private var localSession = Self.makeSession()`.
- **`makeSession()` branches on `#available(iOS 26, *)` + simulator check** and picks real / mock / simulator. This is the one place `#if canImport(FoundationModels)` lives.
- **The native `LanguageModel` / `LanguageModelExecutor` protocols are themselves injection seams.** For new code you can type the holder's dependency as `any LanguageModel` and inject a conforming mock directly, rather than hand-rolling a wrapper protocol. Keep a bespoke wrapper only when you also need to abstract the *simulator* path or non-FM concerns. The `#if canImport` / `@available` discipline is unchanged.

## SwiftUI Integration

- **Chat-style views bind to `@Bindable` session objects.** The session is the view model; don't duplicate its state into `@State`.
- **Disable the send button on `isGenerating`**, not on `isEmpty(inputText)`. Both conditions matter, but missing the `isGenerating` guard causes double-submits.
- **Session objects belong above the navigation boundary** that cancels them — don't stash them in a leaf view whose lifetime is shorter than the conversation.

## Accessibility for Streamed Output

- While `isGenerating`, set `.accessibilityLabel(Strings.Accessibility.chatAssistantThinking)` (localized). Once the stream finishes, swap to `.accessibilityLabel(message.content)`.
- Don't announce every token — VoiceOver will stutter. Let the final label update handle it.
- Apply all existing [`apple-accessibility-best-practices.md`](./apple-accessibility-best-practices.md) rules to AI-generated content: localized labels, `.accessibilityHidden(true)` on decorative "thinking" indicators, context menu actions mirrored in `.accessibilityActions`.

## Patterns to Follow

```swift
// Session holder — @MainActor @Observable, session is optional + lazy
@MainActor
@Observable
final class ChatSession: ChatSessionProtocol {
    private(set) var messages: [ChatMessage] = []
    private(set) var isGenerating = false
    private(set) var error: String?

    private var session: LanguageModelSession?
    private var lastConfig: ResponseLength?

    func send(_ prompt: String, config: ResponseLength) async {
        defer { isGenerating = false }
        isGenerating = true

        if session == nil || lastConfig != config {
            session = makeSession(for: config)
            lastConfig = config
        }
        guard let session else { return }

        let placeholder = ChatMessage(role: .assistant, content: "")
        messages.append(placeholder)
        let placeholderID = placeholder.id

        do {
            for try await chunk in session.streamResponse(to: prompt) {
                if Task.isCancelled { break }
                updateMessage(id: placeholderID, appending: chunk)
            }
        } catch {
            messages.removeAll { $0.id == placeholderID }
            self.error = error.localizedDescription
        }
    }
}

// Availability — surface via @Observable, handle each reason
@MainActor
@Observable
final class AppleIntelligenceSupport {
    private(set) var isAvailable = false
    private(set) var unavailabilityReason: String?

    func refresh() {
        switch SystemLanguageModel.default.availability {
        case .available:
            isAvailable = true
            unavailabilityReason = nil
        case .unavailable(.deviceNotEligible):
            isAvailable = false
            unavailabilityReason = nil  // hide UI entirely
        case .unavailable(.appleIntelligenceNotEnabled):
            isAvailable = false
            unavailabilityReason = String(localized: Strings.AI.enableInSettings)
        case .unavailable(.modelNotReady):
            isAvailable = false
            unavailabilityReason = String(localized: Strings.AI.modelDownloading)
        @unknown default:
            isAvailable = false
            unavailabilityReason = String(localized: Strings.AI.unavailable)
        }
    }
}

// Factory — picks real / mock / simulator
@MainActor
static func makeSession() -> any ChatSessionProtocol {
    #if targetEnvironment(simulator)
    return SimulatorChatSession()
    #else
    if #available(iOS 26, *), SystemLanguageModel.default.availability == .available {
        return RealChatSession()
    }
    return MockChatSession()
    #endif
}
```
