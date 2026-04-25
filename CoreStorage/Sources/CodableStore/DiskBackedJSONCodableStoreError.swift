//
//  DiskBackedJSONCodableStoreError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import Foundation

// MARK: - DiskBackedJSONCodableStoreError

/// Errors that may be thrown by ``DiskBackedJSONCodableStore``.
public enum DiskBackedJSONCodableStoreError: LocalizedError, CustomStringConvertible, @unchecked Sendable {

    /// A file system operation failed.
    case fileManagerError(cause: Error)

    /// Encoding the data to JSON failed.
    case encodingFailure(cause: Error)

    /// Writing data to disk failed.
    case writeFailure(cause: Error)

    /// Reading data from disk failed.
    case readFailure(cause: Error)

    /// Decoding JSON data failed.
    case decodingFailure(cause: Error)

    public var description: String {
        switch self {
        case .fileManagerError(let cause):
            return "FileManagerError(cause: \(String(describing: cause)))"
        case .encodingFailure(let cause):
            return "EncodingFailure(cause: \(String(describing: cause)))"
        case .writeFailure(let cause):
            return "WriteFailure(cause: \(String(describing: cause)))"
        case .readFailure(let cause):
            return "ReadFailure(cause: \(String(describing: cause)))"
        case .decodingFailure(let cause):
            return "DecodingFailure(cause: \(String(describing: cause)))"
        }
    }

    public var errorDescription: String? { description }
}
