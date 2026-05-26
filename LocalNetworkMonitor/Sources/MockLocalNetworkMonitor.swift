//
//  MockLocalNetworkMonitor.swift
//
//  Copyright © Kozinga. All rights reserved.
//

// MARK: - MockLocalNetworkMonitor

/// Mock implementation of ``LocalNetworkMonitorProtocol`` for tests
/// and SwiftUI previews. Connectivity state is settable so a test can
/// simulate joining / leaving a local network without involving
/// `NWPathMonitor` or the OS network stack.
///
/// Setting ``isOnLocalNetwork`` synchronously fires
/// ``LocalNetworkMonitorDelegate/localNetworkMonitor(didChangeIsOnLocalNetwork:)``
/// on the registered delegate when the value differs from the
/// previous one — same external contract as the production monitor,
/// just without the async path-monitor hop.
///
/// ## Example
///
/// ```swift
/// let monitor = MockLocalNetworkMonitor(initialIsOnLocalNetwork: false)
/// let viewModel = MyViewModel(monitor: monitor)
///
/// // Simulate the user joining Wi-Fi mid-test.
/// monitor.isOnLocalNetwork = true
/// #expect(viewModel.showsNoNetworkBanner == false)
/// ```
///
/// ## Topics
///
/// ### Creating a Mock
///
/// - ``init(initialIsOnLocalNetwork:)``
///
/// ### Subscribing to Updates
///
/// - ``delegate``
///
/// ### Driving State From Tests
///
/// - ``isOnLocalNetwork``
/// - ``reset()``
///
/// ### Verifying Lifecycle Calls
///
/// - ``startCallCount``
/// - ``stopCallCount``
///
/// ### Lifecycle
///
/// - ``start()``
/// - ``stop()``
@MainActor
public final class MockLocalNetworkMonitor: LocalNetworkMonitorProtocol {

    public weak var delegate: LocalNetworkMonitorDelegate?

    public var isOnLocalNetwork: Bool {
        get { _isOnLocalNetwork }
        set {
            guard newValue != _isOnLocalNetwork else { return }
            _isOnLocalNetwork = newValue
            delegate?.localNetworkMonitor(didChangeIsOnLocalNetwork: newValue)
        }
    }
    private var _isOnLocalNetwork: Bool

    // MARK: - Test Tracking

    /// The number of times ``start()`` has been called.
    public var startCallCount = 0

    /// The number of times ``stop()`` has been called.
    public var stopCallCount = 0

    // MARK: - Initialization

    /// - Parameter initialIsOnLocalNetwork: Seed value for
    ///   ``isOnLocalNetwork`` before any explicit mutation. Defaults
    ///   to `true` to match the production monitor's optimistic
    ///   initial state.
    public init(initialIsOnLocalNetwork: Bool = true) {
        self._isOnLocalNetwork = initialIsOnLocalNetwork
    }

    // MARK: - Lifecycle

    public func start() {
        startCallCount += 1
    }

    public func stop() {
        stopCallCount += 1
    }

    /// Resets call counts and connectivity state to defaults.
    public func reset() {
        startCallCount = 0
        stopCallCount = 0
        _isOnLocalNetwork = true
    }
}
