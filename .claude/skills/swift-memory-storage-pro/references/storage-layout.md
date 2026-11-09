# Storage layout

## Directory decision table

| Data | Location | Backed up | System may delete |
|---|---|---|---|
| Files the user created and expects in Files | `URL.documentsDirectory` | Yes | No |
| App state, databases, settings files | `URL.applicationSupportDirectory` | Yes | No |
| Large re-downloadable content that must stay offline | Application Support, in a directory with `isExcludedFromBackup` | No | No |
| Re-creatable caches (thumbnails, API responses, prefetch) | `URL.cachesDirectory` | No | Yes, when space is low |
| Scratch files for one operation | `FileManager.default.temporaryDirectory` | No | Yes |
| Data shared with extensions or widgets | App group container (`containerURL(forSecurityApplicationGroupIdentifier:)`) | Yes, same rules by subdirectory | No |
| Secrets (tokens, passwords, keys) | Keychain | Depends on accessibility class | No |
| Small preferences | `UserDefaults` | Yes | No |

The `URL.…Directory` properties are iOS 16+ / macOS 13+; on older targets use `FileManager.default.urls(for:in:)`.

Findings to look for:

- Caches, thumbnails, or downloaded media in Documents: iCloud backup bloat. App Review rejects apps that back up large amounts of re-downloadable data.
- Offline content (downloads the user asked for) in Caches: the system deletes it when space is low and the user's "downloaded" episode is gone.
- Writes to `Bundle.main` paths: fail on device.
- Absolute container paths persisted in a database or defaults: the container path changes between installs and sometimes launches. Store paths relative to a known directory.
- Application Support used without creating it first: the first write fails.

## Backup exclusion

```swift
func makeOfflineDirectory() throws -> URL {
    var url = URL.applicationSupportDirectory.appending(path: "Offline", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try url.setResourceValues(values)
    return url
}
```

- Setting it on the directory excludes its contents. Setting it per file is fragile: an atomic write replaces the file and the new file doesn't carry the flag.
- Re-apply it on launch if the directory might have been recreated.

## UserDefaults

- For flags, small strings, numbers, dates, and short arrays. The whole domain is read into memory at first access, and every write rewrites the plist.
- Not for: `Data` blobs, encoded model arrays that grow, images, caches, secrets.
- `@AppStorage` is UserDefaults with the same limits.
- tvOS has no guaranteed persistent local storage; store state in iCloud (`NSUbiquitousKeyValueStore` for small values, CloudKit for more) and treat local files as a cache.
- Every app that touches UserDefaults declares `NSPrivacyAccessedAPICategoryUserDefaults` (reason CA92.1 for the app's own defaults).

## Keychain

- Store tokens, passwords, and private keys as generic-password items (`kSecClassGenericPassword`) under a service name.
- Accessibility:
  - `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`: foreground-only secrets.
  - `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`: tokens a background refresh, push handler, or extension needs.
  - The `ThisDeviceOnly` variants don't migrate to a new device through backup; use the non-`ThisDeviceOnly` variant only when restoring the secret on a new device is intended.
- Share with extensions through a keychain access group.
- Items survive app deletion on iOS. If a fresh install must start signed out, check a "has launched" flag in UserDefaults (which is deleted with the app) and delete stale items when it's missing.

## File protection

| Class | Readable | Use for |
|---|---|---|
| `.complete` | Only while unlocked | Sensitive files the app reads in the foreground |
| `.completeUnlessOpen` | Open handles stay usable after lock; new files can be created while locked | Files written by a download that finishes after lock |
| `.completeUntilFirstUserAuthentication` (default) | After the first unlock since boot | Most app data, and anything background tasks read |
| `.none` | Always | Rarely justified |

```swift
try data.write(to: url, options: [.atomic, .completeFileProtection])
```

A background task that reads a `.complete` file while the device is locked gets a permission error; pick the class by when the file is read.

## App group containers

- One container per app group, shared by the app and its extensions.
- Two processes writing the same file need coordination: `NSFileCoordinator` for files, or a single writer (the app) and read-only extensions. SQLite stores (Core Data, SwiftData) in a shared container need care: see `coredata-swift6-pro`.
- Widgets should read small, pre-rendered data the app writes; they shouldn't open the app's full database.

## Writing safely

- `.atomic` writes to a temporary file and renames it, so readers never see a partial file.
- File I/O on the main actor freezes the UI; do it from an actor or a `nonisolated` async function and hop back with the result.
- After `URLSession.download`, move the file to its final location before anything slow; the temporary file isn't yours to keep.
- Copying a SQLite store means copying the `-wal` and `-shm` files too, or using the persistence framework's migrate/replace API.

## Free space

```swift
let values = try URL.applicationSupportDirectory.resourceValues(
    forKeys: [.volumeAvailableCapacityForImportantUsageKey])
if let free = values.volumeAvailableCapacityForImportantUsage, free < Int64(requiredBytes) {
    throw StorageError.insufficientSpace(needed: requiredBytes, available: free)
}
```

- `ForImportantUsage` for work the user asked for (the system may free purgeable space to make room); `ForOpportunisticUsage` for prefetch and optional downloads.
- These are required-reason APIs: declare `NSPrivacyAccessedAPICategoryDiskSpace` (E174.1 to check before writing, 85F4.1 to display it to the user).
- Handle `CocoaError.fileWriteOutOfSpace` with a user-facing message.

## Cache budgets and cleanup

- `URLCache.shared` defaults are small; set an explicit `URLCache(memoryCapacity:diskCapacity:)` sized for the app, or a dedicated cache per `URLSessionConfiguration`.
- Image and media caches get a disk size limit and LRU eviction.
- On launch, delete tmp files older than a day and orphaned partial downloads.
- Apps that store a lot (media, maps, offline content) show what they use and offer per-item deletion and "Clear cache".

## App size

- Asset catalogs enable app thinning (per-device slices of images); loose PNGs in the bundle don't thin.
- Large optional content (levels, language packs, high-resolution media) belongs in Background Assets (Apple-hosted asset packs, introduced with iOS 26); On-Demand Resources is legacy and shouldn't be used for new content.
- Export with an App Thinning Size Report (`xcodebuild -exportArchive` with thinning enabled in the export options) and compare per-variant sizes release to release.
- Strip unused architectures and debug symbols from embedded frameworks; ship dSYMs separately (`apple-testflight-deployment.md`).

## Privacy manifest reasons for storage APIs

| API family | Category | Common reason |
|---|---|---|
| `volumeAvailableCapacity…`, `systemFreeSize`, `statfs` | `NSPrivacyAccessedAPICategoryDiskSpace` | E174.1 (check before writing) |
| `creationDate`, `modificationDate`, `contentModificationDateKey`, `attributesOfItem`, `stat` | `NSPrivacyAccessedAPICategoryFileTimestamp` | C617.1 (files in your container) |
| `UserDefaults` | `NSPrivacyAccessedAPICategoryUserDefaults` | CA92.1 |

A required-reason API used without its category in `PrivacyInfo.xcprivacy` blocks App Store upload. Third-party SDKs ship their own manifests; check them when an SDK writes files.
