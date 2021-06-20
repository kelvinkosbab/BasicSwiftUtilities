//
//  Locale+Util.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

// MARK: - Country

/// Struct with information about a Country including ISO country code and name.
public struct Country : Hashable {
    
    /// ISO country code.
    let code: String
    
    /// Country name.
    let name: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.code)
    }
    
    public static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code
    }
}

// MARK: - Locale

public extension Locale {
    
    /// The set of known country or region codes.
    ///
    /// Not all country or region codes have supporting locale data in the system.
    static var isoCountryCodes: Set<String> {
        return Set(NSLocale.isoCountryCodes)
    }
    
    /// Returns a locale identifier from the components specified in a given dictionary.
    ///
    /// This reverses the actions of components(fromLocaleIdentifier:), so for example the dictionary
    /// {NSLocaleLanguageCode="en", NSLocaleCountryCode="US", NSLocaleCalendar=NSJapaneseCalendar}
    /// becomes "en_US@calendar=japanese".
    ///
    /// - Parameter dict: A dictionary containing components that specify a locale. For possible values,
    /// see NSLocale Component Keys.
    ///
    /// - Returns A locale identifier created from the components specified in dict.
    static func localeIdentifier(fromComponents components: [String : String]) -> String {
        return NSLocale.localeIdentifier(fromComponents: components)
    }
    
    /// The set of known countries or regions.
    ///
    /// Not all countries or regions have supporting locale data in the system.
    static var countries: Set<Country> {
        var countries: Set<Country> = Set()
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [String(NSLocale.Key.countryCode.rawValue) : code])
            if let currentLanguage = self.preferredLanguages.first,
               let name = NSLocale(localeIdentifier: currentLanguage).displayName(forKey: .identifier, value: id) {
                let country = Country(code: code, name: name)
                countries.insert(country)
            }
        }
        return countries
    }
}
