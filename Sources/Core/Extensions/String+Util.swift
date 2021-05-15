//
//  String+Util.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

public extension String {
    
    var trim: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var urlEncoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    var urlDecoded: String? {
        return self.removingPercentEncoding
    }
    
    func removeWhitespaces() -> String {
        return self.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
    }
}
