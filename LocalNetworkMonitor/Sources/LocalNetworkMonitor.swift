//
//  LocalNetworkMonitor.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import Network
import Core

// MARK: - LocalNetworkMonitor

/// Production implementation of ``LocalNetworkMonitorProtocol`` backed
/// by Apple's `Network.framework` `NWPathMonitor`.
///
/// "On local network" is defined as a satisfied path that uses Wi-Fi
/// (every Apple platform) or wired Ethernet (Mac). Cellular-only and
/// offline both report as `false` — Bonjour / mDNS doesn't traverse
/// either of those, so consuming UIs can render a distinct, actionable
/// empty state instead of the generic "no results found".
///
/// ## Lifetime
///
/// Typically owned by a long-lived view model. The monitor stays
/// running for the life of that owner; calls to ``stop()`` cancel the
/// underlying `NWPathMonitor` and the class doesn't hold a reference
/// cycle to the system queue, so deallocation is clean even if
/// `stop()` is missed.
///
/// ## Threading
///
/// `NWPathMonitor.start(queue:)` requires a `DispatchQueue` — that
/// part of Apple's API isn't async-await-native and there's no way
/// around it. What we *can* do (and do here) is keep dispatch queues
/// confined to that single API requirement and read path updates back
/// through an `AsyncStream`, so the rest of the class is pure Swift
/// Concurrency: a structured `Task` iterating `for await path in …`
/// and calling `@MainActor` methods directly. No manual `Task {
/// @MainActor in … }` hops, no dedicated queue we have to name or
/// maintain.
@MainActor
public final class LocalNetworkMonitor: LocalNetworkMonitorProtocol {

    // MARK: - Properties

    public weak var delegate: LocalNetworkMonitorDelegate?

    /// Optimistically `true` until the first `NWPathMonitor` update
    /// arrives. Path updates land near-immediately after ``start()``,
    /// so the optimistic default avoids a one-frame flash of "no local
    /// network" UI while the framework is initializing.
    public private(set) var isOnLocalNetwork: Bool = true

    private let pathMonitor = NWPathMonitor()

    /// The structured consumer task. Owns the `AsyncStream`'s lifetime
    /// — cancelling this task ends the `for await` loop, which finishes
    /// the stream via `defer`, which in turn invokes the stream's
    /// `onTermination` to cancel the underlying `NWPathMonitor`.
    /// ``stop()`` is a single `monitorTask?.cancel()` away from a clean
    /// shutdown.
    private var monitorTask: Task<Void, Never>?

    private let logger: Loggable = Logger(
        subsystem: "com.kozinga.BasicSwiftUtilities.LocalNetworkMonitor",
        category: "LocalNetworkMonitor"
    )

    // MARK: - Initialization

    public init() {}

    deinit {
        // Best-effort cleanup if a caller forgot to stop us. `Task.cancel`
        // and `NWPathMonitor.cancel()` are both documented safe to call
        // from any context.
        monitorTask?.cancel()
        pathMonitor.cancel()
    }

    // MARK: - Lifecycle

    public func start() {
        guard monitorTask == nil else { return }

        // Build the bridge: the path monitor's callback yields into
        // `continuation`; the structured task below iterates `stream`
        // with `for await`. `bufferingNewest(1)` is correct because
        // we only care about the *latest* path — if a burst of updates
        // arrives faster than we drain, dropping stale intermediate
        // ones is fine; the final-state classification is what matters.
        let (stream, continuation) = AsyncStream<NWPath>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )

        // When the stream is dropped (Task cancellation, or
        // explicit `continuation.finish()` below), cancel the
        // underlying path monitor. Belt-and-suspenders alongside the
        // `stop()` path; covers the case where the owning
        // `LocalNetworkMonitor` is released without `stop()` being
        // called.
        continuation.onTermination = { [pathMonitor] _ in
            pathMonitor.cancel()
        }

        // The framework still demands a `DispatchQueue` here, but we
        // don't manage one — `.global(qos: .utility)` is the system's
        // shared pool. The closure runs there, yields into the stream,
        // and that's the last we see of dispatch.
        pathMonitor.pathUpdateHandler = { path in
            continuation.yield(path)
        }
        pathMonitor.start(queue: .global(qos: .utility))

        // Structured consumption. The Task inherits the enclosing
        // `@MainActor` isolation, but `Self.isLocalNetworkPath(_:)`
        // is `nonisolated` (a pure function on `NWPath`) so the
        // classification doesn't pin the main actor for long. The
        // resulting `handlePathUpdate` call is already on the main
        // actor — no hop needed.
        monitorTask = Task { [weak self] in
            defer { continuation.finish() }
            for await path in stream {
                let newValue = Self.isLocalNetworkPath(path)
                self?.handlePathUpdate(isOnLocalNetwork: newValue)
            }
        }

        logger.info("Started — initial optimistic state: isOnLocalNetwork=true")
    }

    public func stop() {
        guard monitorTask != nil else { return }
        // Cancelling the task ends `for await`, which fires the
        // stream's `onTermination` (cancels the path monitor) and
        // the `defer { continuation.finish() }` (drops the stream).
        // The whole chain unwinds from one `cancel()`.
        monitorTask?.cancel()
        monitorTask = nil
        logger.info("Stopped")
    }

    // MARK: - Path Classification

    /// "On local network" means a satisfied path on an interface that
    /// can carry mDNS / DNS-SD to the local link — Wi-Fi everywhere,
    /// plus wired Ethernet on Mac. Cellular alone is explicitly
    /// excluded: the carrier strips mDNS traffic, so even an
    /// otherwise-online iPhone won't discover anything from there.
    ///
    /// `nonisolated` because it's a pure function on `NWPath` — both
    /// the framework's `pathUpdateHandler` (non-main-actor) and the
    /// main-actor consumer task call into it without crossing
    /// isolation boundaries.
    ///
    /// Internal so test code can drive the classifier directly with
    /// synthetic `NWPath` values, but not exposed publicly because
    /// the rule is part of the package's contract and shouldn't be
    /// negotiable from outside.
    nonisolated static func isLocalNetworkPath(_ path: NWPath) -> Bool {
        guard path.status == .satisfied else { return false }
        return path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet)
    }

    private func handlePathUpdate(isOnLocalNetwork newValue: Bool) {
        guard newValue != self.isOnLocalNetwork else { return }
        self.isOnLocalNetwork = newValue
        logger.info("Connectivity changed: isOnLocalNetwork=\(newValue)")
        delegate?.localNetworkMonitor(didChangeIsOnLocalNetwork: newValue)
    }
}
