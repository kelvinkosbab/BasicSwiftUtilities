//
//  DiskBackedJSONCodableStoreError.swift
//
//
//  Created by Kelvin Kosbab on 6/8/23.
//

import Foundation

// MARK: - DiskBackedJSONCodableStoreError

/// An enumeration of the erros that may be thrown by the `DiskBackedJSONCodableStore`.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public enum DiskBackedJSONCodableStoreError: Error, CustomStringConvertible {

    case fileManagerError(cause: Error)
    case encodingFailure(cause: Error)
    case writeFailure(cause: Error)
    case readFailure(cause: Error)
    case decodingFailure(cause: Error)

    public var description: String {
        switch self {
        case .fileManagerError(let cause):
            return "FileManagerError(cause: \(String(describing: cause))"
        case .encodingFailure(let cause):
            return "EncodingFailure(cause: \(String(describing: cause))"
        case .writeFailure(let cause):
            return "WriteFailure(cause: \(String(describing: cause))"
        case .readFailure(let cause):
            return "ReadFailure(cause: \(String(describing: cause))"
        case .decodingFailure(let cause):
            return "DecodingFailure(cause: \(String(describing: cause))"
        }
    }
}
