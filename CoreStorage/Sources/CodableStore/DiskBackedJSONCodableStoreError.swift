//
//  DiskBackedJSONCodableStoreError.swift
//
//  Copyright © Kozinga. All rights reserved.
//

public import Foundation

// MARK: - DiskBackedJSONCodableStoreError

/// Errors that may be thrown by ``DiskBackedJSONCodableStore``.
///
/// The underlying cause is stored as a string description rather than the original
/// `Error` value. This keeps the type genuinely `Sendable` (the existential `any Error`
/// is not `Sendable`) and is sufficient for diagnostic logging — log the original error
/// at the throw site if you need richer fidelity.
public enum DiskBackedJSONCodableStoreError: LocalizedError, CustomStringConvertible, Sendable {

    /// A file system operation failed.
    case fileManagerError(cause: String)

    /// Encoding the data to JSON failed.
    case encodingFailure(cause: String)

    /// Writing data to disk failed.
    case writeFailure(cause: String)

    /// Reading data from disk failed.
    case readFailure(cause: String)

    /// Decoding JSON data failed.
    case decodingFailure(cause: String)

    public var description: String {
        switch self {
        case .fileManagerError(let cause):
            return "FileManagerError(cause: \(cause))"
        case .encodingFailure(let cause):
            return "EncodingFailure(cause: \(cause))"
        case .writeFailure(let cause):
            return "WriteFailure(cause: \(cause))"
        case .readFailure(let cause):
            return "ReadFailure(cause: \(cause))"
        case .decodingFailure(let cause):
            return "DecodingFailure(cause: \(cause))"
        }
    }

    public var errorDescription: String? { description }
}
