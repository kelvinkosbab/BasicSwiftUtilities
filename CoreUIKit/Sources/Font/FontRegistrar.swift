//
//  FontRegistrar.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

public import UIKit

/// Programmatically registers fonts for an application.
public final class FontRegistrar: Sendable {

    /// Creates a new font registrar.
    public init() {}

    /// Object to hold the information about a registered font.
    private struct RegisteredFont: Hashable, Sendable {

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
    private nonisolated(unsafe) static var registeredFonts: Set<RegisteredFont> = Set()

    /// Registers a given font.
    ///
    /// If a font has already been registered do nothing. (Note: This method registers fonts statically on the
    /// `FontRegistrar` type and does not know of any other fonts that are registered by other methods or types.)
    ///
    /// - Parameter fontName: File name of the font to be registered.
    /// - Parameter fileType: File extension of the font file. `ttf` is the default file format if not provided.
    /// - Parameter bundle: Bundle where the font file is located. (example: `Bundle(for: FontToRegister.self)`)
    /// - Throws: ``FontRegistrationError/registrationFailed(fontName:)`` if the font cannot be loaded
    ///   from the bundle or registered with Core Text.
    public func registerFont(
        named fontName: String,
        fileType: String = "ttf",
        bundle: Bundle
    ) throws {

        let fontToRegister = RegisteredFont(fontName: fontName, fileType: fileType, bundle: bundle)
        guard !FontRegistrar.registeredFonts.contains(fontToRegister) else {
            return
        }

        let pathForResourceString = bundle.path(forResource: fontName, ofType: fileType)
        guard let path = pathForResourceString,
           let fontData = NSData(contentsOfFile: path),
           let dataProvider = CGDataProvider(data: fontData),
           let fontRef = CGFont(dataProvider) else {
               throw FontRegistrationError.registrationFailed(fontName: fontName)
           }

        var errorRef: Unmanaged<CFError>?

        if !CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
            errorRef?.release()
            throw FontRegistrationError.registrationFailed(fontName: fontName)
        }

        FontRegistrar.registeredFonts.insert(fontToRegister)
    }
}

// MARK: - FontRegistrationError

/// Errors thrown by ``FontRegistrar`` during font registration.
public enum FontRegistrationError: LocalizedError, Sendable {

    /// The font failed to load from the bundle or could not be registered with Core Text.
    case registrationFailed(fontName: String)

    public var errorDescription: String? {
        switch self {
        case .registrationFailed(let fontName):
            "Failed to register font \"\(fontName)\". Verify the file exists in the bundle."
        }
    }
}

#endif
