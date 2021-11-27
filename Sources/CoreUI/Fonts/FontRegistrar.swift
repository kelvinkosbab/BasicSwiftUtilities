//
//  FontRegistrar.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import UIKit

/// Programmatically registers fonts for an application.
public class FontRegistrar {
    
    /// Object to hold the information about a registered font.
    private struct RegisteredFont: Hashable {
        let fontName: String
        let fileType: String
        let bundle: Bundle
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.fontName)
            hasher.combine(self.fileType)
            hasher.combine(self.bundle)
        }
        
        static func ==(lhs: RegisteredFont, rhs: RegisteredFont) -> Bool {
            return lhs.fontName == rhs.fontName &&
                lhs.fileType == rhs.fileType &&
                lhs.bundle == rhs.bundle
        }
    }
    
    /// Contains all the fonts that have been registred by the application.
    private static var registeredFonts: Set<RegisteredFont> = Set()
    
    /// Errors that may be thrown during the font registration process.
    enum Error: Swift.Error {
        case fontRegistrationError(name: String)
    }
    
    /// Registers a given font.
    ///
    /// If a font has already been registered do nothing. (Note: This method rergisteres fonts statically on the
    /// `FontRegistrar` type and does not know of any other fonts thay are registred by other methods or types.)
    ///
    /// - Parameter named: File name of the font to be registered.
    /// - Parameter fileType: File extension of the font file. `ttf` is the default file format if not provided.
    /// - Parameter bundle: Bundle where the font file is located. (example: `Bundle(for: FontToRegister.self)`)
    public func registerFont(named fontName: String,
                             fileType: String = "ttf",
                             bundle: Bundle) throws {
        
        let fontToRegistere = RegisteredFont(fontName: fontName, fileType: fileType, bundle: bundle)
        guard !FontRegistrar.registeredFonts.contains(fontToRegistere) else {
            return
        }
        
        let pathForResourceString = bundle.path(forResource: fontName, ofType: fileType)
        guard let path = pathForResourceString,
           let fontData = NSData(contentsOfFile: path),
           let dataProvider = CGDataProvider(data: fontData),
           let fontRef = CGFont(dataProvider) else {
               throw Error.fontRegistrationError(name: fontName)
           }

        var errorRef: Unmanaged<CFError>?

        if !CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
            errorRef?.release()
            throw Error.fontRegistrationError(name: fontName)
        }
        
        FontRegistrar.registeredFonts.insert(fontToRegistere)
    }
}
