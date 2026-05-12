---
description: Enforce modern Objective-C conventions — ARC, nullability, generics, properties, designated initializers, and Swift interop
globs: "**/*.{h,m,mm}"
---

# Modern Objective-C Best Practices

Apply to Objective-C and Objective-C++ source. Pure-C headers (`.h`) inside Apple projects are rare — when one shows up, skip the ObjC-specific rules but keep the general C ones (nullability, no `assert()` for production checks, etc.).

## Memory Management (ARC only)

- **ARC is required.** Never call `-retain`, `-release`, `-autorelease`, or `-dealloc` on `self`. Implement `-dealloc` only for non-ARC resource cleanup (e.g., closing `CFRelease` handles, removing observers).
- **Use `__weak` for delegates and back-references.** A delegate property is `weak`, never `strong` — and inside blocks, use the `__weak typeof(self) weakSelf = self;` then `__strong typeof(weakSelf) strongSelf = weakSelf;` dance to avoid retain cycles without sacrificing nil-safety mid-block.
- **Wrap long loops in `@autoreleasepool { }`** when they create many temporary autoreleased objects. The autorelease pool drains at run-loop boundaries, not loop iterations — without one, memory climbs.

## Nullability Annotations

- **Wrap every header in `NS_ASSUME_NONNULL_BEGIN` / `NS_ASSUME_NONNULL_END`.** This makes `nonnull` the default and forces you to be explicit about every nullable case.
- **Annotate every nullable return, parameter, and property** with `nullable` (Objective-C syntax) — never the C-style `_Nullable` / `_Nonnull` in public Apple-style headers (those are for type-position annotations like `id _Nullable * _Nonnull`).
- **Block parameters get `NS_NOESCAPE`** when the block does not escape the call. Helps Swift interop and the compiler's escape analysis.

## Type System

- **Return `instancetype`, never `id`,** from initializers and factory methods. Lets the caller-side type stay precise without casts.
- **Use lightweight generics on collections:** `NSArray<NSString *> *`, `NSDictionary<NSString *, NSNumber *> *`, `NSSet<MyModel *> *`. Without them, every element is `id` and Swift sees `[Any]`.
- **Forward-declare with `@class` / `@protocol` in headers** instead of importing the full header — speeds compile and prevents circular imports. Import the full header in the `.m`.

## Properties

- **Prefer properties over ivars + manual accessors.** Even private state inside a class extension should be a property unless there's a measured reason not to.
- **Specify ownership explicitly:** `strong` (default for objects), `weak` (delegates, parents), `copy` (always for `NSString`, `NSArray`, `NSDictionary`, blocks — never `strong` for these).
- **`nonatomic` is the default for view-tier code.** `atomic` is rarely what you actually want — it provides single-property atomicity, not multi-property consistency. Only use `atomic` when you've thought it through.
- **Use class extensions (`@interface MyClass () ... @end`) in the `.m`** for private/internal properties and method declarations. Don't put internal API in the public header.

## Initializers

- **Mark the designated initializer with `NS_DESIGNATED_INITIALIZER`.** This makes the compiler enforce that subclasses route through it.
- **Mark inherited initializers as `NS_UNAVAILABLE`** when they shouldn't be called — e.g., a value type that requires its model parameter:

  ```objc
  - (instancetype)initWithModel:(MyModel *)model NS_DESIGNATED_INITIALIZER;
  - (instancetype)init NS_UNAVAILABLE;
  + (instancetype)new NS_UNAVAILABLE;
  ```

- **Never call subclassable methods (`[self ...]`) inside `-init` or `-dealloc`** when they could dispatch to a subclass that depends on fully-initialized state.

## Modern Syntax

- **Use literal and subscript syntax:** `@[a, b]`, `@{ @"key": value }`, `@(intValue)`, `array[0]`, `dict[@"key"] = value`. No `+arrayWithObjects:` / `+dictionaryWithObjects:` in new code.
- **Use modern block syntax** (`^(NSInteger x) { ... }`) and `typedef`'d block types for any block used in a method signature:

  ```objc
  typedef void (^CompletionHandler)(NSError * _Nullable error);
  - (void)performWithCompletion:(NS_NOESCAPE CompletionHandler)completion;
  ```

- **Compare strings with `-isEqualToString:`** (or `-isEqual:` for general comparison). Never `==` — that compares pointer identity.
- **Use `#pragma mark - Section`** for file organization, mirroring `// MARK: -` in Swift.

## Error Handling

- **Out-parameter convention:** `- (BOOL)doThingError:(NSError **)error;`. Return `BOOL` (or a sentinel like `nil` for object-returning methods) and populate `*error` only on failure. Always check `error != NULL` before assigning.
- **Use `NSParameterAssert(condition)`** for precondition checks on parameters; `NSAssert(condition, format)` for invariants. These compile out in release builds. Never use C `assert()` for runtime contract checks — it crashes release builds without a useful message.

## Swift Interop

- **Bridging-header discipline.** Every ObjC header that Swift needs to see must be `#import`ed in `<ProjectName>-Bridging-Header.h`. When you add a new ObjC class that Swift will consume, update the bridging header in the same change.
- **Control Swift-side names with `NS_SWIFT_NAME(...)`** when the auto-translation is awkward:

  ```objc
  + (instancetype)cellWithIdentifier:(NSString *)identifier
      NS_SWIFT_NAME(cell(identifier:));
  ```

- **Use `NS_REFINED_FOR_SWIFT`** to hide a raw ObjC API from Swift so you can wrap it in a Swift extension with better ergonomics. The ObjC method gets a leading `__` underscore on the Swift side.
- **Mark closures `NS_NOESCAPE`** wherever the block does not escape — Swift gets `@noescape`-style behavior, which is what callers expect.
- **`NS_ASSUME_NONNULL_BEGIN` headers** are mandatory for clean Swift interop — without them, every API surface comes through as Swift `T!` (implicitly unwrapped optional), which is a footgun.

## Patterns to Follow

```objc
// Header — MyService.h
#import <Foundation/Foundation.h>

@class MyModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^MyServiceCompletion)(NSArray<MyModel *> * _Nullable results,
                                    NSError * _Nullable error);

@interface MyService : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, weak, nullable) id<MyServiceDelegate> delegate;

- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)fetchResultsWithCompletion:(NS_NOESCAPE MyServiceCompletion)completion
    NS_SWIFT_NAME(fetchResults(completion:));

@end

NS_ASSUME_NONNULL_END

// Implementation — MyService.m
#import "MyService.h"
#import "MyModel.h"

@interface MyService ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation MyService

- (instancetype)initWithIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier.length > 0);
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _session = [NSURLSession sharedSession];
    }
    return self;
}

#pragma mark - Public

- (void)fetchResultsWithCompletion:(NS_NOESCAPE MyServiceCompletion)completion {
    __weak typeof(self) weakSelf = self;
    [self.session dataTaskWithURL:[self resultsURL]
                completionHandler:^(NSData * _Nullable data,
                                    NSURLResponse * _Nullable response,
                                    NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        // ... parse and dispatch ...
    }];
}

@end
```
