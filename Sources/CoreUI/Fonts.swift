//
//  File.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)
import UIKit
#endif

// MARK: - AppFont

public struct AppFont {
    
    // MARK: - Style
    
    public enum Style {
        case systemRegular
        case systemBold
        case systemItalic
        case systemMonospace
        case custom(String)
    }
    
    public static var regular: Style = .systemRegular
    public static var bold: Style = .systemBold
    public static var italic: Style = .systemItalic
    public static var monospace: Style = .systemMonospace
    
    // MARK: - Size
    
    public struct Size {
        static let body: CGFloat = 16
        static let footnote: CGFloat = 13
        static let heading: CGFloat = 20
        static let title: CGFloat = 28
        static let xlTitle: CGFloat = 70
    }
}

// MARK: - UIFont

public extension UIFont {
    
    static func getAppFont(_ style: AppFont.Style, size: CGFloat) -> UIFont {
        switch style {
        case .systemRegular:
            return UIFont.systemFont(ofSize: size)
            
        case .systemBold:
            return UIFont.boldSystemFont(ofSize: size)
            
        case .systemItalic:
            return UIFont.italicSystemFont(ofSize: size)
            
        case .custom(fontName: let fontName):
            if let font = UIFont(name: fontName, size: size) {
                return font
            } else {
                return self.getAppFont(.systemRegular, size: AppFont.Size.body)
            }
            
        case .systemMonospace:
            if #available(iOS 13.0, *) {
                return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
            } else {
                fatalError("Monospace not supported")
            }
        }
    }
}

// MARK: - Body ViewModifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BodyModifier : ViewModifier {
    
    let appFont: AppFont.Style
    
    public func body(content: Content) -> some View {
        switch self.appFont {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.body))
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
                .font(Font.custom(customFont, size: AppFont.Size.body))
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
                .font(Font.custom(customFont, size: AppFont.Size.body))
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
                .font(Font.custom(customFont, size: AppFont.Size.body))
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
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
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
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
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
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
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
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
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
                .font(Font.custom(customFont, size: AppFont.Size.heading))
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
                .font(Font.custom(customFont, size: AppFont.Size.heading))
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
                .font(Font.custom(customFont, size: AppFont.Size.heading))
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
                .font(Font.custom(customFont, size: AppFont.Size.heading))
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
                .font(Font.custom(customFont, size: AppFont.Size.title))
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
                .font(Font.custom(customFont, size: AppFont.Size.title))
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
                .font(Font.custom(customFont, size: AppFont.Size.title))
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
                .font(Font.custom(customFont, size: AppFont.Size.title))
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
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
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
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
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
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
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
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle,
                              weight: .regular,
                              design: .monospaced))
        }
    }
}

// MARK: - View Modifier

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

// MARK: - Previews

#if DEBUG

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct Font_Previews: PreviewProvider {
    
    private static let text = "Hello World!"
    
    static var previews: some View {
        List {
            /*@START_MENU_TOKEN@*/Text(self.text)/*@END_MENU_TOKEN@*/
                .bodyStyle()
            /*@START_MENU_TOKEN@*/Text(self.text)/*@END_MENU_TOKEN@*/
                .footnoteStyle()
            Text(self.text)
                .headingStyle()
            Text(self.text)
                .titleStyle()
            Text(self.text)
                .xlTitleStyle()
        }
        List {
            Text(self.text)
                .bodyBoldStyle()
            Text(self.text)
                .footnoteBoldStyle()
            Text(self.text)
                .headingBoldStyle()
            Text(self.text)
                .titleBoldStyle()
            Text(self.text)
                .xlTitleBoldStyle()
        }
        List {
            Text(self.text)
                .bodyItalicStyle()
            Text(self.text)
                .footnoteItalicStyle()
            Text(self.text)
                .headingItalicStyle()
            Text(self.text)
                .titleItalicStyle()
            Text(self.text)
                .xlTitleItalicStyle()
        }
        List {
            Text(self.text)
                .bodyMonospaceStyle()
            Text(self.text)
                .footnoteMonospaceStyle()
            Text(self.text)
                .headingMonospaceStyle()
            Text(self.text)
                .titleMonospaceStyle()
            Text(self.text)
                .xlTitleMonospaceStyle()
        }
    }
}

#endif
