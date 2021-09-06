//
//  Result.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

// MARK: - Result

/// A simple success vs failure result. The failure result passes an `error: Error` parameter
/// of the error that was thrown.
public enum Result {
    case success
    case failure(Error)
}

/// A result with a defined success return type. The error result passes the error thrown.
public enum CustomResult<Value> {
    case success(Value)
    case failure(Error)
}
