//
//  FontViewModifiers.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - Body ViewModifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BodyModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body,
                              weight: .regular,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BodyBoldModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body,
                              weight: .bold,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BodyItalicModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body,
                              weight: .regular,
                              design: .default)
                        .italic())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BodyMonospaceModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body,
                              weight: .regular,
                              design: .monospaced))
        }
    }
}

// MARK: - Footnote ViewModifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote,
                              weight: .regular,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteBoldModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote,
                              weight: .bold,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteItalicModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote,
                              weight: .regular,
                              design: .default)
                        .italic())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct FootnoteMonospaceModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote,
                              weight: .regular,
                              design: .monospaced))
        }
    }
}

// MARK: - Heading ViewModifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct HeadingModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading,
                              weight: .regular,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct HeadingBoldModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading,
                              weight: .bold,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct HeadingItalicModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading,
                              weight: .regular,
                              design: .default)
                        .italic())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct HeadingMonospaceModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading,
                              weight: .regular,
                              design: .monospaced))
        }
    }
}

// MARK: - Title ViewModifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct TitleModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title,
                              weight: .regular,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct TitleBoldModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title,
                              weight: .bold,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct TitleItalicModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title,
                              weight: .regular,
                              design: .default)
                        .italic())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct TitleMonospaceModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title,
                              weight: .regular,
                              design: .monospaced))
        }
    }
}

// MARK: - XL Title ViewModifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle,
                              weight: .regular,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleBoldModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle,
                              weight: .bold,
                              design: .default))
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleItalicModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle,
                              weight: .regular,
                              design: .default)
                        .italic())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct XlTitleMonospaceModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont,
                                  size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle,
                              weight: .regular,
                              design: .monospaced))
        }
    }
}

// MARK: - View Extension

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    // MARK: - Body
    
    func bodyStyle(appFont: AppFont.Style = AppFont.regular) -> some View {
        self.modifier(BodyModifier(appFont: appFont))
    }
    
    func bodyBoldStyle(appFont: AppFont.Style = AppFont.bold) -> some View {
        self.modifier(BodyBoldModifier(appFont: appFont))
    }
    
    func bodyItalicStyle(appFont: AppFont.Style = AppFont.italic) -> some View {
        self.modifier(BodyItalicModifier(appFont: appFont))
    }
    
    func bodyMonospaceStyle(appFont: AppFont.Style = AppFont.monospace) -> some View {
        self.modifier(BodyMonospaceModifier(appFont: appFont))
    }
    
    // MARK: - Footnote
    
    func footnoteStyle(appFont: AppFont.Style = AppFont.regular) -> some View {
        self.modifier(FootnoteModifier(appFont: appFont))
    }
    
    func footnoteBoldStyle(appFont: AppFont.Style = AppFont.bold) -> some View {
        self.modifier(FootnoteBoldModifier(appFont: appFont))
    }
    
    func footnoteItalicStyle(appFont: AppFont.Style = AppFont.italic) -> some View {
        self.modifier(FootnoteBoldModifier(appFont: appFont))
    }
    
    func footnoteMonospaceStyle(appFont: AppFont.Style = AppFont.monospace) -> some View {
        self.modifier(FootnoteMonospaceModifier(appFont: appFont))
    }
    
    // MARK: - Heading
    
    func headingStyle(appFont: AppFont.Style = AppFont.regular) -> some View {
        self.modifier(HeadingModifier(appFont: appFont))
    }
    
    func headingBoldStyle(appFont: AppFont.Style = AppFont.bold) -> some View {
        self.modifier(HeadingBoldModifier(appFont: appFont))
    }
    
    func headingItalicStyle(appFont: AppFont.Style = AppFont.italic) -> some View {
        self.modifier(HeadingItalicModifier(appFont: appFont))
    }
    
    func headingMonospaceStyle(appFont: AppFont.Style = AppFont.monospace) -> some View {
        self.modifier(HeadingMonospaceModifier(appFont: appFont))
    }
    
    // MARK: - Title
    
    func titleStyle(appFont: AppFont.Style = AppFont.regular) -> some View {
        self.modifier(TitleModifier(appFont: appFont))
    }
    
    func titleBoldStyle(appFont: AppFont.Style = AppFont.bold) -> some View {
        self.modifier(TitleBoldModifier(appFont: appFont))
    }
    
    func titleItalicStyle(appFont: AppFont.Style = AppFont.italic) -> some View {
        self.modifier(TitleItalicModifier(appFont: appFont))
    }
    
    func titleMonospaceStyle(appFont: AppFont.Style = AppFont.monospace) -> some View {
        self.modifier(TitleMonospaceModifier(appFont: appFont))
    }
    
    // MARK: - XL Title
    
    func xlTitleStyle(appFont: AppFont.Style = AppFont.regular) -> some View {
        self.modifier(XlTitleModifier(appFont: appFont))
    }
    
    func xlTitleBoldStyle(appFont: AppFont.Style = AppFont.bold) -> some View {
        self.modifier(XlTitleBoldModifier(appFont: appFont))
    }
    
    func xlTitleItalicStyle(appFont: AppFont.Style = AppFont.italic) -> some View {
        self.modifier(XlTitleItalicModifier(appFont: appFont))
    }
    
    func xlTitleMonospaceStyle(appFont: AppFont.Style = AppFont.monospace) -> some View {
        self.modifier(XlTitleMonospaceModifier(appFont: appFont))
    }
}
