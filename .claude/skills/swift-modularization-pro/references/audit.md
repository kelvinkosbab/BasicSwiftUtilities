# Auditing a modular package

## Inventory

```bash
# Modules and their dependencies, as JSON
swift package dump-package --package-path MyAppPackages > pkg.json

# Each module with its source file count
for d in MyAppPackages/*/Sources; do
  m=${d%/Sources}
  printf "%-28s %4d files\n" "${m##*/}" "$(find "$d" -name '*.swift' | wc -l)"
done

# The app target's Swift files and line counts. Everything except @main and the
# AppShortcutsProvider is a migration candidate.
find MyApp -name '*.swift' | xargs wc -l | sort -n

# Extension targets (widgets, intents, share), which should link package products only
grep -c 'com.apple.product-type.app-extension' MyApp.xcodeproj/project.pbxproj
```

Count before reading files. The counts set the priorities.

## Dependency-rule check

`swift package dump-package` prints each target dependency as `{"byName": [name, condition]}`, `{"target": [name, condition]}`, or `{"product": [name, package, moduleAliases, condition]}`. This script reads that JSON and reports feature→feature edges, upward edges between layers, features importing a concrete backend, and modules without a test target. Edit `LAYERS` and `BACKENDS` for the project. A module with no layer is printed as a note so the table stays complete.

```python
#!/usr/bin/env python3
"""Check a package's module graph against layer rules.

Usage: swift package dump-package --package-path MyAppPackages > pkg.json
       python3 check-module-graph.py pkg.json
"""
import json
import sys

# Edit to match the project. First matching prefix wins; order matters.
LAYERS = [
    ("AppCore", 5),
    ("Feature", 4),
    ("DesignSystem", 3),
    ("Models", 2), ("Storage", 2), ("Localization", 2),
    ("Core", 1),
]
FEATURE_PREFIX = "Feature"
# Concrete backends features may not import: {interface: [implementations]}
BACKENDS = {"SyncCore": ["SyncCloudKit"]}


def layer(name):
    for prefix, rank in LAYERS:
        if name.startswith(prefix):
            return rank
    return None


def dep_name(dep):
    for kind in ("byName", "target", "product"):
        if kind in dep:
            return dep[kind][0]
    return None


def main(path):
    pkg = json.load(open(path))
    targets = {t["name"]: t for t in pkg["targets"]}
    graph = {
        name: [d for d in map(dep_name, t["dependencies"]) if d in targets]
        for name, t in targets.items() if t["type"] == "regular"
    }
    implementations = {i for impls in BACKENDS.values() for i in impls}
    problems = []
    for src, deps in graph.items():
        for dst in deps:
            ls, ld = layer(src), layer(dst)
            if src.startswith(FEATURE_PREFIX) and dst.startswith(FEATURE_PREFIX):
                problems.append(f"feature→feature: {src} → {dst}")
            elif ls is not None and ld is not None and ld > ls:
                problems.append(f"upward edge: {src} (layer {ls}) → {dst} (layer {ld})")
            if src.startswith(FEATURE_PREFIX) and dst in implementations:
                problems.append(f"feature imports concrete backend: {src} → {dst}")
    for name, t in targets.items():
        if t["type"] == "regular" and f"{name}Tests" not in targets:
            problems.append(f"no test target: {name}")
    unranked = sorted(n for n in graph if layer(n) is None and n not in implementations
                      and n not in BACKENDS)
    for name in unranked:
        print(f"note: {name} has no layer; add it to LAYERS")
    for p in problems:
        print(p)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
```

Against a package where `FeatureTasks` imports `FeatureSettings` and `SyncCloudKit`, it prints:

```text
feature imports concrete backend: FeatureTasks → SyncCloudKit
feature→feature: FeatureTasks → FeatureSettings
no test target: DesignSystem
```

and exits 1. Save it as `scripts/check-module-graph.py` in the app repo and run it locally and in CI. Cycles need no script, because SwiftPM refuses to resolve a cyclic graph.

## Searches

```bash
# Resources loaded from the app bundle inside modules (a silent production break)
rg -n 'Bundle\.main' MyAppPackages -g '**/Sources/**'
rg -n '(Image|Color|UIImage|NSImage)\("[^"]+"\)' MyAppPackages -g '**/Sources/**'   # no bundle: argument

# Re-exports; each should carry a comment saying why
rg -n '@_exported import' MyAppPackages

# Logic left in the app target
rg -ln '(ViewModel|Service|Repository|@Observable|URLSession)' MyApp -g '*.swift'

# A moved AppShortcutsProvider (Siri phrases silently lost)
rg -n 'AppShortcutsProvider' MyAppPackages

# Which modules import features (only AppCore should)
rg -l '^import Feature' MyAppPackages -g '**/Sources/**' | cut -d/ -f2 | sort | uniq -c
```

## Check by hand

- **`AppCore` is the only module that imports features**, and only the app target links `AppCore`.
- **Interface modules import no vendor SDK.** Only implementation modules do.
- **Every `@_exported` has a reason written next to it.**
- **Tests that skip under `swift test`** (Core Data models) say why, and assert under `xcodebuild test`.
- **`CLAUDE.md` lists every module** in the manifest, and its graph matches `pkg.json`.

## CI job

```yaml
# .github/workflows/spm-tests.yml
name: Package tests
on:
  pull_request:
    paths: ['MyAppPackages/**', 'scripts/check-module-graph.py', '.github/workflows/spm-tests.yml']
  push:
    branches: [main]
    paths: ['MyAppPackages/**']
jobs:
  test:
    runs-on: macos-26
    steps:
      - uses: actions/checkout@v4
      - name: Check module graph
        run: |
          swift package dump-package --package-path MyAppPackages > pkg.json
          python3 scripts/check-module-graph.py pkg.json
      - run: swift build --package-path MyAppPackages
      - run: swift test --package-path MyAppPackages --parallel
```

The app build (`xcodebuild build` for each shipped platform) and UI tests run in a separate workflow, path-filtered to the project, the app target folder, and the package. Pin the runner image and Xcode version (see `apple-testflight-deployment.md`).
