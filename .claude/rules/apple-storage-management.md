---
description: On-device storage on Apple platforms — choosing Documents / Application Support / Caches / tmp, iCloud backup exclusion, UserDefaults limits, Keychain for secrets, file protection, app group containers, atomic writes, free-space checks, cache budgets, app size, and the disk-space / file-timestamp privacy manifest reasons
globs: "**/*.swift,**/PrivacyInfo.xcprivacy,**/*.entitlements"
paths:
  - "**/*.swift"
  - "**/PrivacyInfo.xcprivacy"
  - "**/*.entitlements"
must:
  - "Put re-creatable caches in Caches and user downloads in Application Support excluded from backup, never in Documents."
  - "Store tokens and passwords in the Keychain, never in UserDefaults, plists, or files."
  - "Write files atomically and off the main actor; check free space before large writes."
  - "Declare disk-space, file-timestamp, and UserDefaults APIs in `PrivacyInfo.xcprivacy`, or the upload is rejected."
---

# Apple Storage Management

Where a file lives decides whether it's backed up, whether the system can delete it, and whether App Review flags the app for bloating iCloud backups. Disk is shared with the user's photos, so an app that grows without bound gets deleted. These are the must-follow rules. Examples, the directory decision table, and the audit workflow live in the **`swift-memory-storage-pro`** skill (`references/storage-layout.md`, `references/measuring.md`). Core Data and SwiftData specifics stay with `coredata-swift6-pro` and `swiftdata-pro`.

## Pick the directory by what the data is

- **Documents** (`URL.documentsDirectory`): only what the user created and would expect to see in Files. Backed up.
- **Application Support** (`URL.applicationSupportDirectory`): app-created state, databases, settings files. Backed up. It doesn't exist on first launch; create it with `createDirectory(at:withIntermediateDirectories: true)`.
- **Caches** (`URL.cachesDirectory`): anything you can download or rebuild. Not backed up; the system deletes it when the device is low on space, so read it as optional.
- **tmp** (`FileManager.default.temporaryDirectory`): scratch files for one operation. Delete them when done.
- **Never write into the app bundle**, and never hard-code container paths; they change between launches.
- **Large downloadable content that must stay offline** (podcasts, maps, offline packs) goes in Application Support with `isExcludedFromBackup = true`. Set it on a dedicated directory, which excludes everything inside, rather than per file (a replaced file loses the flag).
- **tvOS** has no guaranteed persistent local storage: keep state in iCloud (`NSUbiquitousKeyValueStore`, CloudKit) and treat local files as a cache.

## Small values, secrets, and sharing

- **UserDefaults is for small preferences** (flags, a few strings and numbers). Never `Data` blobs, model arrays, images, or anything that grows; the whole domain loads at launch.
- **Secrets live in the Keychain**, never in UserDefaults, plists, or files. Pick accessibility on purpose: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` for tokens used in the background, `WhenUnlockedThisDeviceOnly` otherwise. Keychain items survive app deletion; clear stale ones on the first launch after a reinstall.
- **File protection**: sensitive files not needed while locked get `.completeFileProtection` (`data.write(to:options: [.atomic, .completeFileProtection])`). Files a background task writes while the device is locked need `.completeUntilFirstUserAuthentication` (the default).
- **Share with extensions through the app group container** (`containerURL(forSecurityApplicationGroupIdentifier:)`), and coordinate concurrent writers (`NSFileCoordinator`, or one process owns writes).

## Writing safely

- **Write atomically** (`.atomic`) so a crash or kill mid-write never leaves a half-written file.
- **File I/O stays off the main actor**; read and write large files from an actor or a nonisolated async function.
- **Check free space before large writes and downloads** with `volumeAvailableCapacityForImportantUsage` (user-requested) or `volumeAvailableCapacityForOpportunisticUsage` (prefetch), and handle the out-of-space error with a message, not a crash.
- **Move a downloaded file out of its temporary location** before doing anything slow with it.

## Budgets and cleanup

- **Every disk cache has a size cap and eviction.** Set `URLCache(memoryCapacity:diskCapacity:)` explicitly, cap image-cache disk size, and evict least-recently-used entries.
- **Clean up on a schedule**: delete stale tmp files on launch, and old downloads the user no longer needs.
- **Heavy apps show storage use** and offer "Clear downloads" / "Clear cache" in Settings.
- **App size**: keep large optional content out of the bundle (Background Assets with Apple-hosted asset packs; On-Demand Resources is legacy), use asset catalogs so app thinning applies, and review the App Thinning Size Report before each release.

## Privacy manifest

- **Disk-space APIs** (`volumeAvailableCapacity…`, `systemFreeSize`, `statfs`) need `NSPrivacyAccessedAPICategoryDiskSpace` in `PrivacyInfo.xcprivacy` (E174.1 to check space before writing).
- **File-timestamp APIs** (`creationDate`, `modificationDate`, `contentModificationDateKey`, `attributesOfItem`) need `NSPrivacyAccessedAPICategoryFileTimestamp` (C617.1 for files in your own container).
- **UserDefaults** needs `NSPrivacyAccessedAPICategoryUserDefaults` (CA92.1). A missing reason blocks the upload.
