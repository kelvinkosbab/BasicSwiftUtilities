//
//  LocalNetworkMonitorTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation
import Testing
@testable import LocalNetworkMonitor

// MARK: - LocalNetworkMonitor

@Suite("LocalNetworkMonitor")
@MainActor
struct LocalNetworkMonitorTests {

    // We don't drive `NWPathMonitor` synthetically here — that
    // machinery belongs to Apple and is already battle-tested. The
    // value of these tests is confirming our shim's contract:
    // optimistic default, idempotent start/stop, no crashes on the
    // lifecycle edges.

    @Test("Initial `isOnLocalNetwork` is optimistically `true`")
    func initialStateIsOptimisticTrue() {
        let monitor = LocalNetworkMonitor()
        #expect(monitor.isOnLocalNetwork)
    }

    @Test("`start()` then `stop()` runs cleanly without throwing")
    func startStopLifecycle() {
        let monitor = LocalNetworkMonitor()
        monitor.start()
        monitor.stop()
        // No assertion beyond "didn't crash" — the monitor must
        // survive a synchronous start/stop pair without leaking the
        // dispatch queue or the path monitor.
    }

    @Test("`start()` is idempotent — calling it twice is harmless")
    func startIsIdempotent() {
        let monitor = LocalNetworkMonitor()
        monitor.start()
        monitor.start()
        monitor.stop()
    }

    @Test("`stop()` is idempotent — calling it on an un-started monitor is harmless")
    func stopIsIdempotentEvenWithoutStart() {
        let monitor = LocalNetworkMonitor()
        monitor.stop()
        monitor.stop()
    }

    @Test("Starting again after `stop()` re-arms the monitor cleanly")
    func canStartAfterStop() {
        let monitor = LocalNetworkMonitor()
        monitor.start()
        monitor.stop()
        monitor.start()
        monitor.stop()
    }
}

// MARK: - MockLocalNetworkMonitor

@Suite("MockLocalNetworkMonitor")
@MainActor
struct MockLocalNetworkMonitorTests {

    @Test("Mock defaults to optimistic `isOnLocalNetwork=true`")
    func defaultsToOptimisticTrue() {
        let monitor = MockLocalNetworkMonitor()
        #expect(monitor.isOnLocalNetwork)
    }

    @Test("Mock honors a `false` seed at init time")
    func seedHonored() {
        let monitor = MockLocalNetworkMonitor(initialIsOnLocalNetwork: false)
        #expect(!monitor.isOnLocalNetwork)
    }

    @Test("Mock increments `startCallCount` once per `start` call")
    func startIncrementsCount() {
        let monitor = MockLocalNetworkMonitor()
        monitor.start()
        monitor.start()
        #expect(monitor.startCallCount == 2)
    }

    @Test("Mock increments `stopCallCount` once per `stop` call")
    func stopIncrementsCount() {
        let monitor = MockLocalNetworkMonitor()
        monitor.stop()
        monitor.stop()
        monitor.stop()
        #expect(monitor.stopCallCount == 3)
    }

    @Test("Setting `isOnLocalNetwork` to a new value fires the delegate exactly once")
    func setterFiresDelegateOnChange() {
        let monitor = MockLocalNetworkMonitor()
        let delegate = TestDelegate()
        monitor.delegate = delegate

        monitor.isOnLocalNetwork = false
        #expect(delegate.receivedValues == [false])

        monitor.isOnLocalNetwork = true
        #expect(delegate.receivedValues == [false, true])
    }

    @Test("Setting `isOnLocalNetwork` to the same value is a no-op for the delegate")
    func setterSkipsDelegateWhenUnchanged() {
        let monitor = MockLocalNetworkMonitor(initialIsOnLocalNetwork: false)
        let delegate = TestDelegate()
        monitor.delegate = delegate

        monitor.isOnLocalNetwork = false  // same as initial — no fire
        #expect(delegate.receivedValues.isEmpty)
    }

    @Test("Mock `reset` returns counters and value to defaults")
    func resetReturnsToDefaults() {
        let monitor = MockLocalNetworkMonitor(initialIsOnLocalNetwork: false)
        monitor.start()
        monitor.stop()
        monitor.reset()
        #expect(monitor.startCallCount == 0)
        #expect(monitor.stopCallCount == 0)
        #expect(monitor.isOnLocalNetwork)
    }
}

// MARK: - TestDelegate

/// Records `localNetworkMonitor(didChangeIsOnLocalNetwork:)` callbacks
/// so tests can assert call shape and ordering.
@MainActor
private final class TestDelegate: LocalNetworkMonitorDelegate {
    var receivedValues: [Bool] = []

    func localNetworkMonitor(didChangeIsOnLocalNetwork isOnLocalNetwork: Bool) {
        receivedValues.append(isOnLocalNetwork)
    }
}
