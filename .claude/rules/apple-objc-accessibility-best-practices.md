---
description: Enforce UIKit/AppKit accessibility best practices in Objective-C — labels, traits, Dynamic Type, Reduce Motion, VoiceOver announcements, and modal focus
globs: "**/*.{h,m,mm}"
---

# Objective-C Accessibility Best Practices

Every interactive view must be reachable to VoiceOver, Dynamic Type, and assistive technologies. UIKit/AppKit's accessibility surface is property-based: set `accessibilityLabel`, `accessibilityHint`, `accessibilityTraits`, etc. on the view itself. The defaults are wrong for almost every custom view.

These rules apply to UIKit-based ObjC (`.h`/`.m`/`.mm`). For SwiftUI, see [`apple-accessibility-best-practices.md`](./apple-accessibility-best-practices.md).

## Required Properties

- **`accessibilityLabel`** — short, localized noun phrase describing what the element *is*. Always `NSLocalizedString(...)`, never hardcoded English. *"Send button"* not *"button1"*.
- **`accessibilityHint`** — short, localized description of what happens when the user activates the element. Only set when the label alone isn't enough. *"Submits the form."* Don't repeat the label.
- **`accessibilityValue`** — for stateful controls (sliders, steppers, toggles, segmented controls). Update whenever state changes.
- **`accessibilityTraits`** — bitmask of `UIAccessibilityTrait*` values describing the element's role. See below.
- **`isAccessibilityElement`** — `YES` for views that should be a single VoiceOver node (default depends on the class — set explicitly for clarity).

## `accessibilityIdentifier` vs `accessibilityLabel`

These are **completely different concerns**, frequently confused:

- **`accessibilityLabel`** — user-facing, **must be localized** (`NSLocalizedString`), read aloud by VoiceOver, changes per locale.
- **`accessibilityIdentifier`** — test-only, **never localized**, stable across locales, used by XCUITest to find elements (e.g., `app.buttons[@"send_button"]`).

If you find yourself setting `accessibilityIdentifier` to a localized string, that's wrong — UI tests will break the moment a translation lands.

```objc
// Correct:
self.sendButton.accessibilityLabel = NSLocalizedString(@"a11y.send_button.label", @"VoiceOver label for the send button");
self.sendButton.accessibilityIdentifier = @"send_button";   // stable, locale-free
```

## Traits Reference

Common traits for compound bitmask via `|`:

| Trait | When to use |
|-------|-------------|
| `UIAccessibilityTraitButton` | Custom tappable view that acts like a button |
| `UIAccessibilityTraitLink` | View that navigates somewhere (open URL, push screen) |
| `UIAccessibilityTraitHeader` | Section title text — lets VO users navigate by heading |
| `UIAccessibilityTraitImage` | Image with meaningful content (the label describes it) |
| `UIAccessibilityTraitSelected` | Currently-selected state (apply *only* when selected) |
| `UIAccessibilityTraitNotEnabled` | Disabled state (apply when disabled) |
| `UIAccessibilityTraitAdjustable` | Element responds to swipe-up/swipe-down for incremental adjust |
| `UIAccessibilityTraitUpdatesFrequently` | VO shouldn't announce every change (clocks, progress) |
| `UIAccessibilityTraitStaticText` | Non-interactive text |

```objc
- (UIAccessibilityTraits)accessibilityTraits {
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (self.isSelected)  { traits |= UIAccessibilityTraitSelected; }
    if (!self.isEnabled)  { traits |= UIAccessibilityTraitNotEnabled; }
    return traits;
}
```

**Don't statically assign traits in `init` if state changes** — override the getter or update on state mutation. VoiceOver re-reads traits on focus, so dynamic state must be reflected.

## Localization is Mandatory

Every `accessibilityLabel` / `accessibilityHint` / `accessibilityValue` / custom-action name goes through `NSLocalizedString`. No exceptions, including for "obvious" English words.

```objc
// Wrong — hardcoded English:
cell.accessibilityLabel = @"Delete";

// Right:
cell.accessibilityLabel = NSLocalizedString(@"a11y.delete.label", @"VoiceOver label for the delete swipe action");
```

Use a key-namespacing convention like `a11y.<screen>.<element>.label` to make it obvious in translation tools which strings are a11y-only (so translators can scope context).

## Compound Elements

Default behavior for a container view is "expose every subview separately." That's usually wrong for compound cells (avatar + name + email row). Two patterns:

### Pattern 1: Single composite element

```objc
@implementation UserCell

- (BOOL)isAccessibilityElement { return YES; }

- (NSString *)accessibilityLabel {
    return [NSString stringWithFormat:NSLocalizedString(@"a11y.user_cell.label", @"%1$@ name, %2$@ email"),
            self.nameLabel.text ?: @"",
            self.emailLabel.text ?: @""];
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitButton;
}

@end
```

VoiceOver reads the whole row as one element: *"Alice Smith name, alice@example.com email, button."*

### Pattern 2: Explicit element list

```objc
- (NSArray *)accessibilityElements {
    return @[ self.avatarImageView, self.nameLabel, self.emailLabel, self.chevronImageView ];
}
```

Controls the reading order without merging the subviews. Use when subviews are individually meaningful (e.g., a list of action buttons) but the container's default order is wrong.

## Dynamic Type

User-visible text must scale with the system text-size setting.

```objc
// Wrong — fixed size:
self.titleLabel.font = [UIFont systemFontOfSize:17];

// Right — semantic style + auto-adjust:
self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
self.titleLabel.adjustsFontForContentSizeCategory = YES;
```

- **`preferredFontForTextStyle:`** picks the size from the current `UIContentSizeCategory`.
- **`adjustsFontForContentSizeCategory = YES`** makes the label re-pick its font automatically when the user changes the setting *while the app is running*. Without this, you have to observe `UIContentSizeCategoryDidChangeNotification` yourself.
- **Available text styles:** `UIFontTextStyleLargeTitle`, `Title1`, `Title2`, `Title3`, `Headline`, `Subheadline`, `Body`, `Callout`, `Footnote`, `Caption1`, `Caption2`. Map your design system onto these — don't invent a parallel set.

For text inside a custom-drawn `UIView`, observe `UIContentSizeCategoryDidChangeNotification` and call `setNeedsDisplay` so the redraw picks up the new metrics.

## Reduce Motion

Some users have vestibular sensitivity; respect their preference.

```objc
- (void)animateTransitionTo:(UIView *)next {
    BOOL reduceMotion = UIAccessibilityIsReduceMotionEnabled();
    NSTimeInterval duration = reduceMotion ? 0.0 : 0.3;

    [UIView animateWithDuration:duration animations:^{
        next.alpha = 1.0;
    }];
}
```

- **`UIAccessibilityIsReduceMotionEnabled()`** returns the current setting. Cheap to call; don't cache long-term.
- **Observe `UIAccessibilityReduceMotionStatusDidChangeNotification`** if the UI needs to react to runtime toggles. Most apps don't.
- **What to reduce:** parallax effects, large translate animations, decorative spinners. Replace with cross-fades or instant transitions.
- **What you can keep:** subtle button taps, state-change indicators. Use judgment — a 200 ms color fade is fine; a screen-spanning slide is not.

## VoiceOver Announcements

For transient state changes that aren't tied to a specific focused element (e.g., *"Saved"*, *"Network unavailable"*):

```objc
NSString *message = NSLocalizedString(@"a11y.announcement.saved", @"Announced after successful save");
UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
```

For full-screen content changes (e.g., navigating to a new view that should move VO focus):

```objc
UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.newPrimaryView);
```

Use sparingly. Every announcement interrupts the VoiceOver user — too many is hostile. Save them for confirmations and errors the user genuinely needs to hear.

## Modal Focus

When presenting a custom overlay (not a `UIAlertController` or system sheet), VoiceOver focus can leak to background views.

```objc
- (void)showOverlay:(UIView *)overlay {
    overlay.accessibilityViewIsModal = YES;
    [self.view addSubview:overlay];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, overlay);
}
```

`accessibilityViewIsModal = YES` tells VoiceOver to ignore siblings outside the overlay. Without it, swiping past the overlay surfaces the dimmed-out content beneath.

## Custom Actions

For compound rows where swipe-to-delete / long-press / drag are part of the gesture vocabulary, expose those actions to VoiceOver:

```objc
- (NSArray<UIAccessibilityCustomAction *> *)accessibilityCustomActions {
    UIAccessibilityCustomAction *delete =
        [[UIAccessibilityCustomAction alloc]
            initWithName:NSLocalizedString(@"a11y.row.action.delete", @"Delete action")
                  target:self
                selector:@selector(performDelete)];
    UIAccessibilityCustomAction *edit =
        [[UIAccessibilityCustomAction alloc]
            initWithName:NSLocalizedString(@"a11y.row.action.edit", @"Edit action")
                  target:self
                selector:@selector(performEdit)];
    return @[delete, edit];
}
```

VoiceOver users hear *"actions available"* and rotor-cycle through them. Without this, the swipe/long-press actions are invisible.

## VoiceOver Detection

Sometimes you want to behave differently when VoiceOver is on (e.g., disable a hover-style affordance):

```objc
if (UIAccessibilityIsVoiceOverRunning()) {
    // Show the static fallback instead of the hover preview
}
```

- **`UIAccessibilityIsVoiceOverRunning()`** — runtime state.
- **Observe `UIAccessibilityVoiceOverStatusDidChangeNotification`** if the UI needs to react to toggles.

## Common Pitfalls

- **Hardcoded English in `accessibilityLabel`** — every label must go through `NSLocalizedString`.
- **`accessibilityIdentifier` localized** — identifiers are test handles, never localized. Localize labels; don't localize identifiers.
- **`accessibilityHint` duplicating the label** — *"Send"* + *"Tap to send"* is repetitive. Drop the hint when redundant.
- **`isAccessibilityElement = YES` on a container** — the container becomes one element AND its subviews disappear from VoiceOver. Either set this on the container with merged label/traits *or* leave it off; don't both.
- **`accessibilityTraits = UIAccessibilityTraitButton` set once in `init`** — state changes (selected, disabled) won't be reflected. Override the getter or update on mutation.
- **Fixed-point font sizes** (`systemFontOfSize:17`) — text won't scale with Dynamic Type. Use semantic styles.
- **`adjustsFontForContentSizeCategory` left at default `NO`** — Dynamic Type works only on first display, not on runtime changes.
- **`UIAccessibilityPostNotification` called too often** — every announcement interrupts the user. Use only for transient state the user *needs* to know about.
- **Custom overlay without `accessibilityViewIsModal = YES`** — VoiceOver focus escapes the modal.
- **Long-press / swipe gestures with no `accessibilityCustomActions`** — invisible to VoiceOver users.

## Patterns to Follow

```objc
// Custom button — labels, traits, identifier
@interface SendButton : UIControl
@end

@implementation SendButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = NSLocalizedString(@"a11y.send.label", @"VoiceOver label for the send button");
        self.accessibilityHint = NSLocalizedString(@"a11y.send.hint", @"VoiceOver hint: what happens on tap");
        self.accessibilityIdentifier = @"send_button";   // not localized
    }
    return self;
}

- (UIAccessibilityTraits)accessibilityTraits {
    UIAccessibilityTraits t = UIAccessibilityTraitButton;
    if (!self.isEnabled) { t |= UIAccessibilityTraitNotEnabled; }
    return t;
}

@end
```

```objc
// Dynamic Type for a label
self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
self.titleLabel.adjustsFontForContentSizeCategory = YES;
self.titleLabel.numberOfLines = 0;   // allow wrapping at larger sizes
```

```objc
// Confirmation announcement
- (void)didSaveSuccessfully {
    NSString *message = NSLocalizedString(@"a11y.saved.announcement", @"Announced after successful save");
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
}
```

```objc
// Compound row with custom actions
@implementation UserCell

- (BOOL)isAccessibilityElement { return YES; }

- (NSString *)accessibilityLabel {
    return [NSString stringWithFormat:NSLocalizedString(@"a11y.user_cell.label", @"User cell: %1$@, %2$@"),
            self.user.name ?: @"",
            self.user.email ?: @""];
}

- (UIAccessibilityTraits)accessibilityTraits { return UIAccessibilityTraitButton; }

- (NSArray<UIAccessibilityCustomAction *> *)accessibilityCustomActions {
    return @[
        [[UIAccessibilityCustomAction alloc]
            initWithName:NSLocalizedString(@"a11y.user_cell.action.delete", @"Delete this user")
                  target:self
                selector:@selector(performDelete)],
    ];
}

@end
```
