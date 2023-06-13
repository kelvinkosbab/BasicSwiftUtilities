//
//  Sample.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Sample

/// A sample that represents a piece of data associated with a start and end time.
public struct Sample {
    
    /// The sample's start date.
    public let startDate: Date
    
    /// The sample's end date.
    public let endDate: Date
    
    /// The quantity’s value in the provided unit.
    public let value: Double
    
    /// The measurement unit of the sample.
    public let unit: Unit
}
