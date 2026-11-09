# Recording and reading traces with `xctrace`

> **Sources.** `xctrace help`, `man xctrace`, and Apple's Xcode 27 xctrace agent skill, published by [Artem Novichkov](https://github.com/artemnovichkov) in [`artemnovichkov/xcode-skills`](https://github.com/artemnovichkov/xcode-skills). Rewritten for this bundle.

## Refresh the command surface first

`xctrace` flags change between Xcode releases. Before a session, run `xctrace help`, then `xctrace help <command>` (`record`, `toc`, `list`, `show`, `triage`, `symbolicate`) or `man xctrace`, and use what they print over anything here.

## Recording

```bash
xctrace list templates
xctrace list devices
xctrace record --template 'Time Profiler' --device '<name or UDID>' \
  --time-limit 30s --output ~/scratch/feed.trace --launch -- /path/to/MyApp.app
# or attach to a running process: --attach <pid|name>
```

Pick the template for the question: Time Profiler (CPU time), Hangs or Time Profiler with the Hangs instrument (freezes), System Trace (blocking, scheduling, syscalls), Allocations / Leaks (memory), Animation Hitches (dropped frames). Record a Release-like build on device, reproduce the same steps each time, and keep the trace short.

## How a trace is organized

- **File**: a `.trace` (or `.atrc`, Apple Trace) holding data and symbols.
- **Run**: one recording; a file can hold several, by number or name.
- **Tracks**: *instrument tracks* have fixed titles, one per instrument. *Dynamic tracks* come from a prototype (`Process`, `Process/Thread`, `os_signpost/<subsystem>`), so there's no track literally named "Process"; you list the real ones.
- **Details** on each track: a *list* (table), a *summary* (aggregated), or a *call tree*. Some details have **focus destinations** (rows you can drill into).

## Exploration flow

1. `xctrace toc` on the file: instrument tracks, dynamic-track prototypes, and each one's details (usually under 200 lines).
2. `xctrace list tracks --type "Process/Thread" | grep 'MyApp (1234)/'` to find the concrete dynamic tracks you care about.
3. `xctrace show --track "<track>" --summary "<detail>"` (or the list / call-tree detail) for the data.
4. Drill in with `--focus <ID>` and `--title "<detail>"`, using an id the previous output listed under `focus:`.

Prefer `show` (curated) over `export` (raw XML). Times are integers, nanoseconds by default; some flags accept `s` / `ms` / `us` suffixes.

## Reading a call tree

- **Stochastic** trees (Time Profiler, CPU Profiler) come from samples: proportions are meaningful, absolute completeness isn't. **Deterministic** trees (system calls, allocations, file system) record every event.
- Each metric has a **Self** column (measured in that frame) and a total (self plus descendants). High total, low self: the cost is below. High self: the cost is here.
- `--arrange-columns "# Samples|...|Library Name"` shows hidden columns (`...` stands for the defaults); `--sort "<column>"` reorders.
- Markdown output adds an **is heaviest** column; `grep '|\*|'` extracts the heaviest stack, which is usually the place to start.
- `--include-source-info` adds file and line; `--source` (and `--source-mode`) projects a frame onto source or assembly, useful for spotting Swift runtime calls (retain / release, dynamic casts, existential boxing).

## Symbolication

An unsymbolicated frame shows an address, binary name, offset, and the build's UUID. Find the matching dSYM (`dwarfdump --uuid <dSYM>` must print the same UUID), then `xctrace symbolicate` the trace. A rebuilt binary has a new UUID even from identical source; ask for the dSYM of the build that was traced.

## Output size

| Command | Typical output |
|---|---|
| `toc` | under ~200 lines |
| `list` | hundreds of lines |
| `triage` | hundreds of lines |
| `show` | up to hundreds of kilobytes |

Redirect to a scratch file and read slices (`head`, `grep`), or narrow with `--track`, `--focus`, and the heaviest-stack filter.
