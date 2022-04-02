//
//  String+Util.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

public extension String {
    
    /// Returns a string that trims the leading and trailing edge of a string of any whitespace characters.
    var trim: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns the URL encoded string.
    var urlEncoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    /// Returns the URL decoded string.
    var urlDecoded: String? {
        return self.removingPercentEncoding
    }
    
    /// Returns a string removing all whitespaces of the current string.
    var removeWhitespaces: String {
        return self.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
    }
}
