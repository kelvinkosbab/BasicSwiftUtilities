//
//  Result.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

// MARK: - Result

public enum Result {
    case success
    case failure(Error)
}

public enum CustomResult<Value> {
    case success(Value)
    case failure(Error)
}
