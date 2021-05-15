//
//  File.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - AppFont

public struct AppFont {
    
    // MARK: - StyleType
    
    public enum Style {
        case systemRegular
        case systemBold
        case systemItalic
        case custom(String)
        
        @available(iOS 13, *)
        case systemMonospace
    }
    
    public static var regular: Style = .systemRegular
    public static var bold: Style = .systemBold
    public static var italic: Style = .systemItalic
    
    @available(iOS 13, *)
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
    
    static let body: UIFont = UIFont.getAppFont(AppFont.regular, size: AppFont.Size.body)
    static let bodyBold: UIFont = UIFont.getAppFont(AppFont.bold, size: AppFont.Size.body)
    static let bodyItalic: UIFont = UIFont.getAppFont(AppFont.italic, size: AppFont.Size.body)
    static let bodyMonospace: UIFont = UIFont.getAppFont(AppFont.italic, size: AppFont.Size.body)
    
    static let footnote: UIFont = UIFont.getAppFont(AppFont.regular, size: AppFont.Size.footnote)
    static let footnoteBold: UIFont = UIFont.getAppFont(AppFont.bold, size: AppFont.Size.footnote)
    static let footnoteItalic: UIFont = UIFont.getAppFont(AppFont.italic, size: AppFont.Size.footnote)
    
    @available(iOS 13, *)
    static let footnoteMonospace: UIFont = UIFont.getAppFont(AppFont.monospace, size: AppFont.Size.footnote)
    
    static let heading: UIFont = UIFont.getAppFont(AppFont.regular, size: AppFont.Size.heading)
    static let headingBold: UIFont = UIFont.getAppFont(AppFont.bold, size: AppFont.Size.heading)
    static let headingItalic: UIFont = UIFont.getAppFont(AppFont.italic, size: AppFont.Size.heading)
    
    @available(iOS 13, *)
    static let headingMonospace: UIFont = UIFont.getAppFont(AppFont.monospace, size: AppFont.Size.heading)
    
    static let title: UIFont = UIFont.getAppFont(AppFont.regular, size: AppFont.Size.title)
    static let titleBold: UIFont = UIFont.getAppFont(AppFont.bold, size: AppFont.Size.title)
    static let titleItalic: UIFont = UIFont.getAppFont(AppFont.regular, size: AppFont.Size.title)
    
    @available(iOS 13, *)
    static let titleMonospace: UIFont = UIFont.getAppFont(AppFont.monospace, size: AppFont.Size.title)
    
    static let xlTitle: UIFont = UIFont.getAppFont(AppFont.regular, size: AppFont.Size.xlTitle)
    static let xlTitleBold: UIFont = UIFont.getAppFont(AppFont.bold, size: AppFont.Size.xlTitle)
    static let xlTitleItalic: UIFont = UIFont.getAppFont(AppFont.italic, size: AppFont.Size.xlTitle)
    
    @available(iOS 13, *)
    static let xlTitleMonospace: UIFont = UIFont.getAppFont(AppFont.monospace, size: AppFont.Size.xlTitle)
    
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

// MARK: - Font ViewModifiers

@available(iOS 13, *)
private struct BodyModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body, weight: .regular, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct BodyBoldModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body, weight: .bold, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct BodyMonospaceModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.body))
        default:
            return content
                .font(.system(size: AppFont.Size.body, weight: .regular, design: .monospaced))
        }
    }
}

@available(iOS 13, *)
private struct FootnoteModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote, weight: .regular, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct FootnoteBoldModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote, weight: .bold, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct FootnoteMonospaceModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.footnote))
        default:
            return content
                .font(.system(size: AppFont.Size.footnote, weight: .regular, design: .monospaced))
        }
    }
}

@available(iOS 13, *)
private struct HeadingModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading, weight: .regular, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct HeadingBoldModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading, weight: .bold, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct HeadingMonospaceModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.heading))
        default:
            return content
                .font(.system(size: AppFont.Size.heading, weight: .regular, design: .monospaced))
        }
    }
}

@available(iOS 13, *)
private struct TitleModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title, weight: .regular, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct TitleBoldModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title, weight: .bold, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct TitleMonospaceModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.title))
        default:
            return content
                .font(.system(size: AppFont.Size.title, weight: .regular, design: .monospaced))
        }
    }
}

@available(iOS 13, *)
private struct XlTitleModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.regular {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle, weight: .regular, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct XlTitleBoldModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle, weight: .bold, design: .default))
        }
    }
}

@available(iOS 13, *)
private struct XlTitleMonospaceModifier: ViewModifier {
    public func body(content: Content) -> some View {
        switch AppFont.bold {
        case .custom(let customFont):
            return content
                .font(Font.custom(customFont, size: AppFont.Size.xlTitle))
        default:
            return content
                .font(.system(size: AppFont.Size.xlTitle, weight: .regular, design: .monospaced))
        }
    }
}

@available(iOS 13, *)
public extension View {
    
    func bodyStyle() -> some View {
        self.modifier(BodyModifier())
    }
    
    func bodyBoldStyle() -> some View {
        self.modifier(BodyBoldModifier())
    }
    
    func bodyMonospaceStyle() -> some View {
        self.modifier(BodyMonospaceModifier())
    }
    
    func footnoteStyle() -> some View {
        self.modifier(FootnoteModifier())
    }
    
    func footnoteBoldStyle() -> some View {
        self.modifier(FootnoteBoldModifier())
    }
    
    func footnoteMonospaceStyle() -> some View {
        self.modifier(FootnoteMonospaceModifier())
    }
    
    func headingStyle() -> some View {
        self.modifier(HeadingModifier())
    }
    
    func headingBoldStyle() -> some View {
        self.modifier(HeadingBoldModifier())
    }
    
    func headingMonospaceStyle() -> some View {
        self.modifier(HeadingMonospaceModifier())
    }
    
    func titleStyle() -> some View {
        self.modifier(TitleModifier())
    }
    
    func titleBoldStyle() -> some View {
        self.modifier(TitleBoldModifier())
    }
    
    func titleMonospaceStyle() -> some View {
        self.modifier(TitleMonospaceModifier())
    }
    
    func xlTitleStyle() -> some View {
        self.modifier(XlTitleModifier())
    }
    
    func xlTitleBoldStyle() -> some View {
        self.modifier(XlTitleBoldModifier())
    }
    
    func xlTitleMonospaceStyle() -> some View {
        self.modifier(XlTitleMonospaceModifier())
    }
}

// MARK: - Previews

#if DEBUG

@available(iOS 13, *)
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
