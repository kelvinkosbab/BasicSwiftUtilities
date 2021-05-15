//
//  Locale+Util.swift
//
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

struct IsoCountry {
    let code: String
    let name: String
}

extension IsoCountry : Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.code)
    }
    
    static func ==(lhs: IsoCountry, rhs: IsoCountry) -> Bool {
        return lhs.code == rhs.code
    }
}

extension Locale {
  
    static var isoCountryCodes: [String] {
        return NSLocale.isoCountryCodes as [String]
    }
    
    static func localeIdentifier(fromComponents components: [String : String]) -> String {
        return NSLocale.localeIdentifier(fromComponents: components)
    }
    
    static var countries: [IsoCountry] {
        var countries: [IsoCountry] = []
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [String(NSLocale.Key.countryCode.rawValue) : code])
            if let currentLanguage = self.preferredLanguages.first,
               let name = NSLocale(localeIdentifier: currentLanguage).displayName(forKey: .identifier, value: id) {
                let country = IsoCountry(code: code, name: name)
                countries.append(country)
            }
        }
        let sortedCountries = countries.sorted { (country1, country2) -> Bool in
            return country1.name < country2.name
        }
        return sortedCountries
    }
}
