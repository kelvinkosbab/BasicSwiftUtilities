---
description: Patterns for shipping iOS / macOS / tvOS / watchOS / visionOS apps to TestFlight — versioning, App Store Connect API auth, archive + export, code signing, tester groups, beta review, dSYM upload, CI integration
globs: "**/{Fastfile,Appfile,Matchfile,Deliverfile,Snapfile,Scanfile,Gymfile,exportOptions.plist,ExportOptions.plist,*.entitlements,project.pbxproj,*.yml,*.yaml,Info.plist,*.xcconfig}"
---

# Apple TestFlight Deployment

Shipping a TestFlight build is mostly a sequence of *non-obvious-when-they-fail* steps: version numbers must increment monotonically; the signing certificate must match the provisioning profile must match the team must match the bundle ID; the upload auth must use the right credential type for the right tool. Every one of these has silent-failure modes — a build uploads "successfully" and never appears, or appears in the wrong app, or appears but with a build number Apple has already seen and rejects on the next push.

These rules pin the conventions that catch those failures *before* an upload, and document the canonical paths through the tooling.

## Versioning Discipline

Two numbers, both in `Info.plist`, both critical:

- **`CFBundleShortVersionString`** — the user-visible version, semver-ish (`1.2.3`). Changes triggers beta-review for external testers. Reuse is fine.
- **`CFBundleVersion`** — the build number. **Must monotonically increment on every TestFlight upload.** Apple rejects reuse within a `CFBundleShortVersionString`. Most teams use an integer or `MAJOR.MINOR.BUILD` (e.g., `2024.11.42`).

**Rules of thumb:**
- Bump `CFBundleVersion` on every CI build that's a candidate for upload, not just successful uploads — collisions on retry are the most common upload failure.
- Bump `CFBundleShortVersionString` only when there's a meaningful change in the user-facing version. External testers get a fresh beta review on each `CFBundleShortVersionString` increment.
- **Never** check a hardcoded `CFBundleVersion` into source control. Compute in CI:

  ```bash
  # In a CI step, before `xcodebuild archive`:
  BUILD_NUMBER="$(date +%Y%m%d).${GITHUB_RUN_NUMBER}"   # or any monotonic source
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" ios/MyApp/Info.plist
  ```

  Or via `agvtool`:

  ```bash
  cd ios && agvtool new-version -all "${BUILD_NUMBER}"
  ```

## App Store Connect API Key — the Recommended Auth Path

For CI uploads and automation, App Store Connect API key (.p8) is the supported, modern path. Three pieces:

- **Issuer ID** — UUID identifying your App Store Connect organization. Stable; one per org.
- **Key ID** — short alphanumeric identifying the specific API key. Visible in App Store Connect → Users and Access → Integrations → App Store Connect API.
- **`.p8` private key file** — the actual credential. Download once at key creation; cannot be re-downloaded. Treat like an SSH private key.

**Storage:** all three go in CI secrets. The `.p8` is multi-line — store as a secret with newlines preserved, or base64-encode and decode at use time. The most-deployed Action shape:

```yaml
- name: Install App Store Connect API key
  env:
    ASC_KEY_BASE64: ${{ secrets.ASC_API_KEY_P8_BASE64 }}
  run: |
    mkdir -p ~/.appstoreconnect/private_keys
    echo "$ASC_KEY_BASE64" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8
    chmod 600 ~/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8
```

**Don't use** app-specific passwords for new automations — Apple has deprecated the path; some tools accept them but it's a legacy code path that will be removed.

## Archive + Export + Upload — the Canonical xcodebuild Path

The three-step shape every CI path eventually does:

```bash
# 1. Archive (Release config, .xcarchive bundle on disk)
xcodebuild archive \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/MyApp.xcarchive \
  CODE_SIGN_STYLE=Manual \
  PROVISIONING_PROFILE_SPECIFIER="MyApp App Store" \
  CODE_SIGN_IDENTITY="Apple Distribution: My Team"

# 2. Export the archive into a signed .ipa using an ExportOptions.plist
xcodebuild -exportArchive \
  -archivePath build/MyApp.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/

# 3. Upload (the .ipa lands in TestFlight after Apple's processing — usually 5-30 min)
xcrun altool --upload-app \
  --type ios \
  --file build/MyApp.ipa \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"
```

`xcrun altool --upload-app` is the actively-supported upload path for App Store / TestFlight (the *notarization* side of altool was deprecated in favor of `notarytool` — that's a different command).

## `ExportOptions.plist` — Get the Fields Right

The export step fails or silently mis-signs without the right plist. Minimum viable for TestFlight:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>             <!-- NOT "app-store" — that was renamed -->
    <key>teamID</key>
    <string>ABCDE12345</string>                     <!-- your Team ID, not Team name -->
    <key>uploadBitcode</key>
    <false/>                                        <!-- Bitcode deprecated as of Xcode 14 — set false -->
    <key>uploadSymbols</key>
    <true/>                                         <!-- ON: sends dSYMs with the upload, needed for symbolicated crashes -->
    <key>signingStyle</key>
    <string>manual</string>                         <!-- "manual" for CI; "automatic" for local dev only -->
    <key>provisioningProfiles</key>
    <dict>
        <key>com.example.MyApp</key>                <!-- bundle ID -->
        <string>MyApp App Store</string>            <!-- profile name -->
    </dict>
</dict>
</plist>
```

**Field gotchas:**
- `method` is `app-store-connect` (Xcode 15+) or `app-store` (older). Check what your Xcode version accepts; mismatched values silently produce ad-hoc-signed exports.
- `signingStyle: automatic` only works on a Mac with the developer logged into Xcode — *not* in CI. Use `manual` for CI.
- `provisioningProfiles` is keyed by bundle ID, not target name. Critical when app + extension share a project.

## Code Signing — Two Approaches

**Automatic signing** (Xcode logged-in path): convenient for development, can't run unattended in CI. The Mac's keychain provides the cert; Xcode generates/renews provisioning profiles on demand. Don't use for CI.

**Manual signing** for CI: import an Apple Distribution cert + the matching App Store provisioning profile into the CI runner's keychain before `xcodebuild archive`. Two canonical tools:

- **[`fastlane match`](https://docs.fastlane.tools/actions/match/)** — stores encrypted certs + profiles in a git repo; teams share read access. Decrypted into a CI keychain on each run. Best-supported approach for multi-developer teams.
- **Direct keychain import** — store `.p12` + `.mobileprovision` as base64 CI secrets; decode and import in a setup step. Lighter-weight; works fine for solo teams or one-app shops.

Whichever path: **never check certs or `.p12` files into source control unencrypted.** Even private repos rotate access over time.

## TestFlight Tester Groups — Internal vs External

- **Internal testers**: up to 100 users with App Store Connect access on the team. No beta review required. Builds appear within minutes of finishing Apple's automated processing.
- **External testers**: up to 10,000 users via email. Requires beta review for the **first build of each new `CFBundleShortVersionString`** — subsequent build numbers in the same version go live without review. Reviews typically clear in 24 hours but can stretch to 3-5 days.

**Practical implications:**
- For tight iteration loops, use Internal groups. Beta-review delay is an iteration killer.
- For broader testing or pre-release feedback, push to External and budget 1-2 days for review.
- **Bumping `CFBundleShortVersionString` triggers a new review** for external groups. Don't do it casually mid-cycle.
- Use App Store Connect's "Public Link" feature (a TestFlight invite URL anyone can click) for open beta programs — same external-review rules apply.

## dSYM and Crash Symbolication

When you upload with `uploadSymbols: true` in ExportOptions.plist, Apple receives the dSYMs and uses them for App Store / TestFlight crash logs. But for **Crashlytics**, **Sentry**, or any third-party crash reporter, you upload separately:

- **Crashlytics**: `Firebase Crashlytics upload-symbols` script or the Crashlytics Run Script Build Phase. Wire into the post-archive step.
- **Sentry**: `sentry-cli upload-dsym` after archive.
- **Bitcode-recompiled dSYMs**: not relevant anymore (Bitcode is gone). Skip the "download dSYMs from App Store Connect" dance unless you're on a really old toolchain.

```bash
# In a post-archive CI step, before exportArchive:
find build/MyApp.xcarchive -name "*.dSYM" -print | while read -r dsym; do
    "$FIREBASE_CRASHLYTICS_DSYM_UPLOAD" -gsp ios/GoogleService-Info.plist -p ios "$dsym"
done
```

## Privacy Manifests (`PrivacyInfo.xcprivacy`) — a Hard Upload Gate

Since spring 2024, App Store uploads are validated against privacy manifests. This is the gate **AI-generated code trips most often**: an agent casually adds `UserDefaults`, a file-timestamp check, or `Date` boot-time math, and the next upload bounces with an `ITMS-91053` email because the API was never declared.

- **`NSPrivacyAccessedAPITypes` — declare every "required reason" API you use**, with an allowed reason code. The five categories: `UserDefaults` (`NSPrivacyAccessedAPICategoryUserDefaults` — reason `CA92.1` for app-own data), file timestamps, system boot time, disk space, and active keyboards. `grep` for the APIs before release; don't wait for Apple's email.
- **`NSPrivacyCollectedDataTypes`** — what data the app collects, whether it's linked to identity, and whether it's used for tracking. Must agree with your App Store privacy "nutrition label" answers.
- **`NSPrivacyTracking` + `NSPrivacyTrackingDomains`** — if you track, say so and list the domains; iOS blocks those domains until ATT consent.
- **Third-party SDKs on Apple's "commonly used SDKs" list must ship their *own* privacy manifest and signature.** An outdated Firebase/Facebook/analytics pod without a manifest fails *your* upload (`ITMS-91061`). Keeping deps current is part of release hygiene.
- **Audit with Xcode's privacy report** — archive → Generate Privacy Report — which aggregates your manifest + every SDK's. Review it on each release branch, and re-check whenever a new dependency (especially an analytics or AI SDK) lands.
- **Cloud AI calls are data collection.** Sending user content to a model API typically counts as collected data — update the manifest and the privacy label when you adopt one (see `apple-foundation-models.md`).

## Build Reproducibility

For TestFlight builds you'll have to debug later, make the build reproducible:

- **Lock dependency versions.** `Package.resolved` committed for app targets (un-ignore it). For CocoaPods, `Podfile.lock`. For Carthage, `Cartfile.resolved`.
- **Pin the Xcode version in CI.** GitHub Actions: `xcode-version: 15.4` or use the `actions/setup-xcode` action. Don't rely on "the latest Xcode" — Apple ships breaking changes between minors.
- **Pin Ruby / Bundler / fastlane.** A `Gemfile.lock` + `Bundler` in CI keeps fastlane stable across runs.
- **Stamp the commit SHA into the build.** Easy: a `Bundle short version` or `Info.plist` custom key set from `${GITHUB_SHA}`. Lets you correlate TestFlight builds to source.

### Xcode 27 toolchain notes (Apple silicon, Intel sunset, linker)

Xcode 27 (Swift 6.4) changes the CI baseline — plan for these when you bump the pinned Xcode:

- **Xcode 27 is Apple-silicon-only** and requires **macOS Tahoe 26.4+**. CI runners must be Apple silicon (e.g. GitHub's `macos-15`/`macos-26` ARM images) — an Intel runner can't install it. Pin the runner image, not just the Xcode version.
- **Universal builds drop `x86_64` by default at deployment target ≥ 27.** `ARCHS_STANDARD` no longer includes `x86_64` when `MACOSX_DEPLOYMENT_TARGET` (or `DRIVERKIT_DEPLOYMENT_TARGET`) is `27.0`+. Apple-silicon-only apps get a smaller binary for free; if you still ship Intel, add `x86_64` to `ARCHS` explicitly.
- **`ld64` (the classic linker) is removed; `-ld_classic` is no longer accepted.** Strip any `-ld_classic` from `OTHER_LDFLAGS` / SPM `unsafeFlags` before moving to Xcode 27 — a leftover flag fails the link. The modern linker is the only option.

## CI Patterns — Tool-Agnostic

The deploy-to-TestFlight CI workflow has the same shape regardless of tool:

1. **Checkout** at a known tag/commit.
2. **Install secrets** — `.p8` API key, signing cert, provisioning profile.
3. **Bump `CFBundleVersion`** to a CI-derived monotonic value.
4. **Resolve dependencies** (`xcodebuild -resolvePackageDependencies` or `pod install`).
5. **Archive** (Release config, manual signing).
6. **Upload dSYMs** to Crashlytics/Sentry from the .xcarchive.
7. **Export** the .ipa via `-exportArchive` + ExportOptions.plist.
8. **Upload** to TestFlight via `xcrun altool --upload-app`.
9. **Clean up secrets** — delete the .p8 and signing cert from the runner's keychain.

Tool-specific shapes:

- **fastlane**: a `Fastfile` with `match`, `gym`, `pilot`. Highest community familiarity; lots of plugins. Adds Ruby as a dependency.
- **Xcode Cloud**: Apple's hosted CI. Tightly integrated with App Store Connect. Less flexible than self-hosted but no infra to maintain. Use the App Store Connect → Xcode Cloud config UI; signing is automatic.
- **GitHub Actions** (raw `xcodebuild` calls): no Ruby, no extra runtime, but you write every step yourself. Best for teams that want full control and minimal dependencies.
- **Bitrise**, **CircleCI**, others: similar shape; tool name changes, the nine steps don't.

## Common Gotchas (Ranked by Frequency)

1. **Reusing a `CFBundleVersion`** — Apple's upload API rejects with `ITMS-90161` ("Invalid Provisioning Profile") or `ITMS-90189` ("Bundle Version Mismatch"). Compute build number from a monotonic source.
2. **Mismatched bundle ID between project and provisioning profile** — archive succeeds, export fails with a confusing signing error. Always verify the bundle ID match.
3. **Expired distribution cert** — local archive works, CI upload fails. Apple notifies via email 30 days before expiration; nobody reads it. Calendar reminder yourself.
4. **`signingStyle: automatic` in a CI ExportOptions.plist** — fails on the first CI run with "no signing certificate found." Always `manual` for CI.
5. **`method: app-store` on Xcode 15+** — silently produces an ad-hoc signed export that uploads but never appears in TestFlight. Use `app-store-connect`.
6. **Missing capability entitlements** — push notifications, In-App Purchase, App Groups, iCloud all need explicit entitlements files. Missing them causes silent runtime failures testers report as "crash on launch."
7. **dSYMs not uploaded to Crashlytics** — crashes from testers show as obfuscated addresses, not symbol names. Wire the upload into the CI archive step, not the build script.
8. **Build uploaded to wrong app** — happens when Xcode is configured with two ASC orgs and the wrong issuer/teamID combo is used. Verify the upload appears in the right app within 30 minutes.
9. **External tester invitation emails caught in spam** — corporate testers often don't get the invite. Direct them to the TestFlight app on their phone and the public link (Settings → TestFlight) as a fallback.
10. **Skipping `uploadSymbols: true`** — App Store Connect crash logs show as raw addresses. Set it true unless you have a specific reason not to.

## Patterns to Follow

```yaml
# .github/workflows/testflight.yml — minimum-viable canonical shape
name: TestFlight

on:
  workflow_dispatch:           # manual trigger; add `push: tags: ['v*']` for tag-based releases
  push:
    branches: [main]
    paths: ['ios/**']

jobs:
  testflight:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Set up Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with: { xcode-version: '15.4' }

      - name: Install ASC API key
        env:
          ASC_KEY_BASE64: ${{ secrets.ASC_API_KEY_P8_BASE64 }}
          ASC_KEY_ID:     ${{ secrets.ASC_KEY_ID }}
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "$ASC_KEY_BASE64" | base64 --decode \
            > "$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"

      - name: Install signing cert + profile
        env:
          P12_BASE64:           ${{ secrets.DIST_CERT_P12_BASE64 }}
          P12_PASSWORD:         ${{ secrets.DIST_CERT_P12_PASSWORD }}
          PROFILE_BASE64:       ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD:    ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          # Create a CI keychain, import cert, install profile.
          security create-keychain -p "$KEYCHAIN_PASSWORD" ci.keychain
          security default-keychain -s ci.keychain
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" ci.keychain
          echo "$P12_BASE64" | base64 --decode > /tmp/dist.p12
          security import /tmp/dist.p12 -k ci.keychain -P "$P12_PASSWORD" \
            -T /usr/bin/codesign -T /usr/bin/security
          security set-key-partition-list -S apple-tool:,apple:,codesign: \
            -s -k "$KEYCHAIN_PASSWORD" ci.keychain
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROFILE_BASE64" | base64 --decode \
            > ~/Library/MobileDevice/Provisioning\ Profiles/MyApp_AppStore.mobileprovision

      - name: Bump build number
        run: |
          BUILD_NUMBER="$(date +%Y%m%d).${{ github.run_number }}"
          /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" ios/MyApp/Info.plist

      - name: Archive
        run: |
          xcodebuild archive \
            -workspace ios/MyApp.xcworkspace \
            -scheme MyApp \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            -archivePath build/MyApp.xcarchive \
            CODE_SIGN_STYLE=Manual

      - name: Upload dSYMs to Crashlytics
        run: |
          find build/MyApp.xcarchive -name "*.dSYM" -print0 | xargs -0 -I {} \
            ./ios/Pods/FirebaseCrashlytics/upload-symbols \
              -gsp ios/MyApp/GoogleService-Info.plist -p ios {}

      - name: Export .ipa
        run: |
          xcodebuild -exportArchive \
            -archivePath build/MyApp.xcarchive \
            -exportOptionsPlist ios/ExportOptions.plist \
            -exportPath build/

      - name: Upload to TestFlight
        env:
          ASC_KEY_ID:     ${{ secrets.ASC_KEY_ID }}
          ASC_ISSUER_ID:  ${{ secrets.ASC_ISSUER_ID }}
        run: |
          xcrun altool --upload-app \
            --type ios \
            --file build/MyApp.ipa \
            --apiKey "$ASC_KEY_ID" \
            --apiIssuer "$ASC_ISSUER_ID"

      - name: Clean up secrets
        if: always()
        run: |
          security delete-keychain ci.keychain || true
          rm -f /tmp/dist.p12
          rm -rf ~/.appstoreconnect/private_keys
```

For fastlane equivalent, `Fastfile`:

```ruby
default_platform(:ios)
platform :ios do
  lane :beta do
    app_store_connect_api_key(
      key_id:      ENV["ASC_KEY_ID"],
      issuer_id:   ENV["ASC_ISSUER_ID"],
      key_filepath: ENV["ASC_KEY_PATH"]    # path to the .p8 file
    )
    match(type: "appstore", readonly: is_ci)
    increment_build_number(xcodeproj: "MyApp.xcodeproj")
    build_app(scheme: "MyApp", export_method: "app-store-connect")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end
end
```
