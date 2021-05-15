//
//  Data+Json.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

public extension Data {
    
    var json: Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
    
    var jsonDictionary: [AnyHashable : Any]? {
        if let object = try? JSONSerialization.jsonObject(with: self, options: []), let json = object as? [AnyHashable : Any] {
            return json
        }
        return nil
    }
    
    var jsonArray: [Any]? {
        if let object = try? JSONSerialization.jsonObject(with: self, options: []), let array = object as? [Any] {
            return array
        }
        return nil
    }
}
