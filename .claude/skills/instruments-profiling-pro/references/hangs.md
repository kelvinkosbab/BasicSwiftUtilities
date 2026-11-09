# Triaging hangs

> **Sources.** Apple's Hangs instrument documentation and Apple's Xcode 27 xctrace hangs-triage agent skill, published by [Artem Novichkov](https://github.com/artemnovichkov) in [`artemnovichkov/xcode-skills`](https://github.com/artemnovichkov/xcode-skills). Rewritten for this bundle.

A hang is a stretch where the main thread can't respond to input or update the UI. People feel it as a freeze, an ignored tap, or a stalled animation.

## Severity tiers

`xctrace triage --style hangs` (on a trace that includes the Hangs instrument) sorts each hang by duration:

| Tier | Longer than | Meaning |
|---|---|---|
| Potential Interaction Delay | 33 ms | noticeable lag; often behind hitches |
| Brief Unresponsiveness | 100 ms | the app feels sluggish |
| Microhang | 250 ms | a visible freeze |
| Hang | 500 ms | a clear freeze |
| Severe Hang | 2 s | people force-quit; the system may treat the app as unresponsive |

Dropped animation and scroll frames are **hitches**, a different measurement: use the Animation Hitches template, not hangs triage.

## Busy or blocked first

Before reading a call tree, decide which kind the hang is:

- **Busy**: the main thread's CPU use is high during the hang. Read the **time profile** for that interval (heavy decoding, layout, synchronous work that belongs off the main actor).
- **Blocked**: CPU is low. Read **system calls** and thread states for that interval (synchronous I/O, a lock, a semaphore, `DispatchQueue.sync`, waiting on another thread or process).

Many hangs are both. Settle which dominates, then look at the rest.

## Pitfalls

- The time profile isn't the only source. Use `xctrace toc` to see what else the trace recorded (system calls, thread states, signposts, file activity) and cross-check the hypothesis there.
- If the trace lacks the data (no System Trace for a blocked hang, no signposts around the suspect work), ask for a new recording with it rather than guessing.
- Confirm the fix by re-recording the same steps and comparing tiers and durations, not by reading code.
