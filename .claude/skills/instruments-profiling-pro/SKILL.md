---
name: instruments-profiling-pro
description: Profiles Apple-platform apps from the command line with xctrace (Instruments) — recording traces, exploring .trace and .atrc files with toc / list tracks / show, reading and arranging call trees, symbolicating, keeping output small enough to read, and triaging hangs (busy vs. blocked, severity tiers). Use when an app is slow, uses too much CPU, freezes or hangs, when measuring an optimization, or whenever a trace file needs reading.
license: MIT
metadata:
  author: AppBootstrapAI contributors
  version: "1.0"
  grounded_in: "Apple Instruments and xctrace documentation (xctrace help, man xctrace) and the xctrace agent skill Apple ships with Xcode 27 (as published by Artem Novichkov in artemnovichkov/xcode-skills)"
---

Find out where an app spends time, using `xctrace`, Instruments' command-line interface, so an agent can record and read traces without the Instruments UI.

> **Sources.** Grounded in Apple's Instruments documentation and in the xctrace skill Apple bundles with Xcode 27, which [Artem Novichkov](https://github.com/artemnovichkov) extracted and published in [`artemnovichkov/xcode-skills`](https://github.com/artemnovichkov/xcode-skills). The guidance is rewritten and condensed for this bundle, not copied. `xctrace` changes between Xcode releases: refresh the command surface with `xctrace help` before relying on any flag here.

Process:

1. **State the question first**: which interaction is slow, on which device and build, and what "fixed" means (a number). Profile a Release-like build on a real device; the simulator and Debug builds mislead.
2. **Record or open the trace** and explore it with `references/xctrace.md` (`toc` → `list tracks` → `show`).
3. **For freezes and hangs**, triage with `references/hangs.md` before reading call trees.
4. **Find the heaviest path** in the call tree, map it to source, and propose one change.
5. **Measure again** with the same template, device, and steps, and report before / after numbers.

## Core Instructions

- **Measure, don't guess.** Every claim about a hot spot cites a track and a number from the trace.
- **Keep output readable.** `triage` prints hundreds of lines and `show` can print far more. Redirect to a file in the scratch directory and read slices; never stream a whole call tree into context.
- **Symbolicate before reading.** Hex addresses mean the dSYM didn't match (`dwarfdump --uuid` on both sides).
- **One change per measurement.** Two fixes in one run hide which one helped.
- Cross-reference: memory growth and leaks go to `swift-memory-storage-pro`; main-actor and Task structure to `swift-concurrency-pro`; SwiftUI invalidation to `swiftui-pro`; signposts for custom intervals to `swift-logging-pro` (`OSSignposter`).

## Output Format

Report the question, the trace (template, device, build), the finding with its numbers and source location, the proposed change, and the before / after measurement.

Example:

**Scrolling the feed hangs for 640 ms (Hang tier) on first load.** Main thread busy: 82% of samples under `FeedViewModel.load()` → `JSONDecoder.decode` (`FeedViewModel.swift:48`). Move decoding off the main actor; after the change the longest main-thread interval is 90 ms (no hang reported).
