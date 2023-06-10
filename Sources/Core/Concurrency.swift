//
//  Concurrency.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Concurrency

/// Suspends the current task, then calls the given closure with an unsafe throwing continuation for the current task. Supports a
/// `void` return type.
///
/// - Parameter fn: A closure that takes an `UnsafeContinuation` parameter.
/// You must resume the continuation exactly once.
///
/// If `resume(throwing:)` is called on the continuation,
/// this function throws that error.
///
/// Example:
/// ```swift
/// public func asyncFunction() async throws {
///     try await withUnsafeThrowingVoidContinuation { continuation in
///         fetchResultWithCompletion { result in
///             switch result {
///             case .success:
///                 continuation.resume()
///             case .failure(let error):
///                 continuation.resume(throwing: error)
///             }
///         }
///     }
/// }
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func withUnsafeThrowingVoidContinuation(_ fn: (UnsafeContinuation<Void, Error>) -> Void) async throws {
    try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
        fn(continuation)
    }
}

/// Suspends the current task, then calls the given closure with an unsafe throwing continuation for the current task. Supports a
/// `void` return type.
///
/// - Parameter fn: A closure that takes an `UnsafeContinuation` parameter.
/// You must resume the continuation exactly once.
///
/// Example:
/// ```swift
/// public func asyncFunction() async throws {
///     await withUnsafeVoidContinuation { continuation in
///         fetchResultWithCompletion { result in
///             continuation.resume()
///         }
///     }
/// }
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func withUnsafeVoidContinuation(_ fn: (UnsafeContinuation<Void, Never>) -> Void) async {
    await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
        fn(continuation)
    }
}

/// Suspends the current task, then calls the given closure with an unsafe throwing continuation for the current task. Supports a
/// `void` return type.
///
/// - Parameter fn: A closure that takes an `UnsafeContinuation` parameter.
/// You must resume the continuation exactly once.
///
/// If `resume(throwing:)` is called on the continuation,
/// this function throws that error.
///
/// Example:
/// ```swift
/// public func asyncFunction() async throws {
///     try await withCheckedThrowingVoidContinuation { continuation in
///         fetchResultWithCompletion { result in
///             switch result {
///             case .success:
///                 continuation.resume()
///             case .failure(let error):
///                 continuation.resume(throwing: error)
///             }
///         }
///     }
/// }
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func withCheckedThrowingVoidContinuation(_ fn: (CheckedContinuation<Void, Error>) -> Void) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        fn(continuation)
    }
}

/// Suspends the current task, then calls the given closure with an unsafe throwing continuation for the current task. Supports a
/// `void` return type.
///
/// - Parameter fn: A closure that takes an `UnsafeContinuation` parameter.
/// You must resume the continuation exactly once.
///
/// Example:
/// ```swift
/// public func asyncFunction() async throws {
///     await withUnsafeVoidContinuation { continuation in
///         fetchResultWithCompletion { result in
///             continuation.resume()
///         }
///     }
/// }
/// ```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func withCheckedVoidContinuation(_ fn: (CheckedContinuation<Void, Never>) -> Void) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        fn(continuation)
    }
}
