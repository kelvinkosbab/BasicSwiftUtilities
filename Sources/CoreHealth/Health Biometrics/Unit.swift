//
//  Unit.swift
//
//  Created by Kelvin Kosbab on 8/3/22.
//

import Foundation
import HealthKit

// MARK: - Unit

/// Representation of a quantity chosen as a standard in terms of which other quantities may be expressed.
///
/// **Apple's documentation:**
///
/// Unit strings are composed of the following units:
/// International System of Units (SI) units:
/// - `g                (grams)   [Mass]`
/// - `m                (meters)  [Length]`
/// - `L,l              (liters)  [Volume]`
/// - `Pa               (pascals) [Pressure]`
/// - `s                (seconds) [Time]`
/// - `J                (joules)  [Energy]`
/// - `K                (kelvin)  [Temperature]`
/// - `S                (siemens) [Electrical Conductance]`
/// - `Hz               (hertz)   [Frequency]`
/// - `mol<molar mass>  (moles)   [Mass] <molar mass> is the number of grams per mole. For example, mol<180.1558>`
/// - `V                (volts)   [Electrical Potential Difference]`
/// - `W                (watts)   [Power]`
/// - `rad              (radians) [Angle]`
///
/// **SI units can be prefixed as follows:**
///
/// - `da   (deca-)   = 10                 d    (deci-)   = 1/10`
/// - `h    (hecto-)  = 100                c    (centi-)  = 1/100`
/// - `k    (kilo-)   = 1000               m    (milli-)  = 1/1000`
/// - `M    (mega-)   = 10^6               mc   (micro-)  = 10^-6`
/// - `G    (giga-)   = 10^9               n    (nano-)   = 10^-9`
/// - `T    (tera-)   = 10^12              p    (pico-)   = 10^-12`
/// - `                                    f    (femto-)  = 10^-15`
///
/// **Non-SI units:**
///
/// **Mass**
///
/// - `oz   (ounces)  = 28.3495 g`
/// - `lb   (pounds)  = 453.592 g`
/// - `st   (stones)  = 6350.0 g`
///
/// **Length**
///
/// - `in   (inches)  = 0.0254 m`
/// - `ft   (feet)    = 0.3048 m`
/// - `mi   (miles)   = 1609.34 m`
///
/// **Pressure**
///
/// - `mmHg (millimeters of Mercury)    = 133.3224 Pa`
/// - `cmAq (centimeters of water)      = 98.06650 Pa`
/// - `atm  (atmospheres)               = 101325.0 Pa`
/// - `dBASPL (sound pressure level)    = 10^(dBASPL/20) * 2.0E-05 Pa`
/// - `inHg (inches of Mercury)         = 3386.38816 Pa`
///
/// **Volume**
///
/// - `fl_oz_us  (US customary fluid ounces)= 0.0295735295625 L`
/// - `fl_oz_imp (Imperial fluid ounces)    = 0.0284130625 L`
/// - `pt_us     (US customary pint)        = 0.473176473 L`
/// - `pt_imp    (Imperial pint)            = 0.56826125 L`
/// - `cup_us    (US customary cup)         = 0.2365882365 L`
/// - `cup_imp   (Imperial cup)             = 0.284130625 L`
///
/// **Time**
///
/// - `min  (minutes) = 60 s`
/// - `hr   (hours)   = 3600 s`
/// - `d    (days)    = 86400 s`
///
/// **Energy**
///
/// - `cal  (calories)     = 4.1840 J`
/// - `kcal (kilocalories) = 4184.0 J`
///
/// **Temperature**
///
/// - `degC (degrees Celsius)    = 1.0 K - 273.15`
/// - `degF (degrees Fahrenheit) = 1.8 K - 459.67`
///
/// **Pharmacology**
///
/// - `IU   (international unit)`
///
/// **Scalar**
///
/// - `count = 1`
/// - `%     = 1/100`
///
/// **Hearing Sensitivity**
///
/// - `dBHL (decibel Hearing Level)`
///
///
/// Units can be combined using multiplication (. or *) and division (/), and raised to integral powers (^).
/// For simplicity, only a single '/' is allowed in a unit string, and multiplication is evaluated first.
/// So "kg/m.s^2" is equivalent to "kg/(m.s^2)" and "kg.m^-1.s^-2".
///
/// The following methods convert between HKUnit and Foundation formatter units for mass, length and energy.
/// When converting from Foundation formatter unit to HKUnit, if there's not a match, nil will be returned.
/// When converting from HKUnit to the Foundation formatter unit, if there's not a match, an exception will be thrown.
public protocol Unit {
    
    /// A string representation of the unit. For example for a meter, the `rawValue` returns `m`.
    var rawValue: String { get }
}

@available(macOS 13.0, *)
internal extension Unit {
    
    var healthKitUnit: HKUnit {
        return HKUnit(from: self.rawValue)
    }
}
