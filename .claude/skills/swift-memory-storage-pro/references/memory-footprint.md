# Memory footprint

iOS, iPadOS, watchOS, tvOS, and visionOS have no swap. When an app's footprint passes its limit, the system terminates it (jetsam) without a crash report. The limit depends on the device and the process type, so measure on the smallest device you support.

## Images

Decoded image memory is `width × height × bytes per pixel` (4 for sRGB, 8 for wide-color 16-bit), independent of the file size. A 4032 × 3024 photo decodes to about 48 MB.

```swift
// Before: decodes the full image, then scales it on draw
let image = UIImage(data: data)

// After (iOS 15+): decode straight to the display size
let size = CGSize(width: 120 * displayScale, height: 120 * displayScale)
let thumbnail = await UIImage(data: data)?.byPreparingThumbnail(ofSize: size)
```

ImageIO, without decoding the original first (works on every Apple platform, and from a file URL without loading the data):

```swift
func downsample(_ url: URL, maxPixelSize: CGFloat) -> CGImage? {
    let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }
    let options = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
    ] as CFDictionary
    return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
}
```

Notes:

- Run downsampling off the main actor; cache the result, not the original.
- `UIImage(named:)` caches in a system cache that's purged under pressure; fine for small bundled assets. `UIImage(contentsOfFile:)` doesn't cache.
- SwiftUI `AsyncImage` doesn't downsample or cache decoded images; for grids of remote photos use a loader that downsamples (or an image library configured to).
- `Image(uiImage:).resizable().frame(…)` scales on draw; the full bitmap is still in memory.

## Caches

```swift
@MainActor
final class ThumbnailCache {
    private let cache: NSCache<NSURL, UIImage> = {
        let c = NSCache<NSURL, UIImage>()
        c.totalCostLimit = 50 * 1024 * 1024 // bytes
        return c
    }()
    func insert(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.scale * image.size.height * image.scale * 4)
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
    func image(for url: URL) -> UIImage? { cache.object(forKey: url as NSURL) }
}
```

- `NSCache` evicts under pressure and is internally thread-safe, but it isn't `Sendable`. Keep it isolated: `@MainActor` as above when the UI reads it, or an actor when background work fills it. Never `@unchecked Sendable` (`apple-swift6-strict-concurrency.md`).
- A `[Key: Value]` dictionary on a singleton or long-lived service never shrinks. Flag it when values are large or keys are unbounded (URLs, IDs).
- Set `countLimit` or `totalCostLimit`; without either, `NSCache` still grows until pressure.

## Memory warnings and pressure

- iOS family: `UIApplication.didReceiveMemoryWarningNotification` (or `applicationDidReceiveMemoryWarning`). Drop caches and anything rebuildable.
- macOS: `DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])`.
- A warning may not arrive before termination when growth is fast (a burst of image decodes). Don't depend on it; bound the footprint up front.
- `os_proc_available_memory()` (iOS 13+, iOS family) returns the bytes left before the limit. Check it before an optional large allocation (a high-resolution export, a big ML model) and degrade instead of dying.

## Collections and loading

- `List`, `LazyVStack`, `LazyHStack`, `LazyVGrid` create rows on demand. `VStack` / `HStack` with `ForEach` create every row at once.
- Don't fetch whole tables into arrays: page (Core Data `fetchBatchSize`, SwiftData `fetchLimit`/`fetchOffset`, or a cursor API) and drop pages that scrolled away when they're large.
- Value types copy on write. Passing a large array is cheap until someone mutates a shared copy; a mutation inside a loop on a copy duplicates the buffer every time.

## Streaming large data

- `Data(contentsOf: url, options: .mappedIfSafe)` maps the file instead of reading it into memory.
- `FileHandle` / `AsyncBytes` (`url.resourceBytes`, `FileHandle.bytes`) to process line by line or chunk by chunk.
- `URLSession.download(from:)` / download tasks write to disk; `data(from:)` holds the whole response in memory. Use downloads for anything over a few MB.
- `JSONDecoder` needs the whole document in memory; for very large payloads, page the API.

## Autorelease pools

Objective-C APIs (UIKit images, `NSString`, Foundation collections bridged from ObjC) return autoreleased objects that live until the pool drains, which on the main thread is the end of the run-loop turn. A loop that processes thousands of images grows until it ends.

```swift
for url in urls {
    autoreleasepool {
        if let image = downsample(url, maxPixelSize: 512) { write(image) }
    }
}
```

Pure Swift code doesn't need this.

## Budgets by process

- **App extensions** run with much smaller limits than the containing app. Widgets, notification service extensions, share extensions, and custom keyboards are typically limited to a few tens of MB; exceeding it kills the extension silently (the widget shows its placeholder, the notification arrives unmodified).
  - Widgets: render from small pre-sized images written by the app into the app group container, not originals.
  - Notification service extensions: download attachments to disk; never decode them.
- **watchOS** devices have far less memory than phones; load less and page aggressively.
- **visionOS**: RealityKit assets count; see `apple-visionos-best-practices.md` for triangle and texture budgets.
- **`com.apple.developer.kernel.increased-memory-limit`** (iOS 15+) raises the limit on devices that support it. It's a last resort for genuinely large working sets (games, pro media, on-device ML). It isn't granted on every device, so the app still has to handle the normal limit; never use it to hide a leak. `extended-virtual-addressing` is a separate entitlement for address space, not for memory.
