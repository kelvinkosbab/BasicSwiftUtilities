//
//  Concurrency.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - Concurrency

/// Suspends the current task,
/// then calls the given closure with an unsafe throwing continuation for the current task.
///
/// - Parameter fn: A closure that takes an `UnsafeContinuation` parameter.
/// You must resume the continuation exactly once.
///
/// If `resume(throwing:)` is called on the continuation,
/// this function throws that error.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func withContinuation(_ fn: (UnsafeContinuation<Void, Error>) -> Void) async throws {
    try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
        fn(continuation)
    }
}
