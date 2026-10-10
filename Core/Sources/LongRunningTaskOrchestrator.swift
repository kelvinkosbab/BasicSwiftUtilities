//
//  LongRunningTaskOrchestrator.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - Types

/// A function to call when a registered long-running task has finished its work.
public typealias DoneWorking = @MainActor @Sendable () -> Void

// MARK: - LongRunningTaskOrchestrator

/// Orchestrates tasks that should continue running when the app enters the background.
///
/// Register a task before beginning long-running work. The orchestrator will manage the
/// `UIApplication` background task lifecycle, including timeout and OS expiration handling.
///
/// ```swift
/// let done = await LongRunningTaskOrchestrator.shared.register(taskName: "sync")
/// // ... perform work ...
/// await done()
/// ```
///
/// For more information see
/// [`UIApplication.beginBackgroundTask`](https://developer.apple.com/documentation/uikit/uiapplication/1623051-beginbackgroundtask).
public actor LongRunningTaskOrchestrator {

    // MARK: - Singleton

    /// The shared orchestrator instance.
    public static let shared = LongRunningTaskOrchestrator()

    // MARK: - Properties

    private let logger: Loggable = Logger(
        subsystem: "com.kozinga.BasicSwiftUtilities.Core",
        category: "LongRunningTaskOrchestrator"
    )

    // MARK: - Result

    /// The possible outcomes of a long-running background task.
    public enum Result: Sendable {

        /// The OS cancelled the task because it took too long.
        case expiredByOS

        /// The task was cancelled because it exceeded the specified timeout.
        case timeout

        /// The task completed normally.
        case completed
    }

    // MARK: - Register

    /// Registers a long-running task that should continue in the background.
    ///
    /// - Parameter taskName: A descriptive name shown in the debugger.
    /// - Parameter timeout: Maximum duration in seconds before the task times out. Defaults to 60.
    /// - Returns: A ``DoneWorking`` closure to call when the task completes.
    @MainActor
    public func register(
        taskName: String,
        timeout: Double = 60
    ) -> DoneWorking {
        let start = ProcessInfo.processInfo.systemUptime
        let logger = self.logger
        let state = BackgroundTaskState()

        logger.info("\(taskName): Registering task")

        let endTask: @MainActor @Sendable (Result) -> Void = { result in
            if state.backgroundTaskId == .invalid {
                logger.info("\(taskName): Stopping duplicate task")
            } else {
                let duration = Int(ProcessInfo.processInfo.systemUptime - start)
                logger.info("\(taskName): Task has completed with \(String(describing: result)). Task duration = \(duration)s.")
                UIApplication.shared.endBackgroundTask(state.backgroundTaskId)
                state.backgroundTaskId = .invalid
            }
        }

        state.timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(timeout))
            } catch {
                // Cancelled before the timeout fired — the task completed or the OS expired it first.
                return
            }
            let duration = Int(ProcessInfo.processInfo.systemUptime - start)
            logger.info("\(taskName): Task never responded and has timed out after \(duration)s. Releasing task.")
            endTask(.timeout)
        }

        state.backgroundTaskId = UIApplication.shared.beginBackgroundTask(
            withName: "LongRunningTaskOrchestrator.\(taskName)"
        ) {
            logger.info("\(taskName): OS is expiring the task. Releasing task.")
            endTask(.expiredByOS)
            state.timeoutTask?.cancel()
        }

        if state.backgroundTaskId == .invalid {
            logger.info("\(taskName): Task execution denied")
        }

        return {
            logger.info("\(taskName): Caller signaled task has completed. Releasing task.")
            endTask(.completed)
            state.timeoutTask?.cancel()
        }
    }
}

// MARK: - BackgroundTaskState

/// Mutable state shared by the closures of a single ``LongRunningTaskOrchestrator/register(taskName:timeout:)``
/// call. Main-actor isolation makes it `Sendable`, so the `@Sendable` completion, timeout, and
/// expiration closures can all share it without data races.
@MainActor
private final class BackgroundTaskState {
    var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    var timeoutTask: Task<Void, Never>?
}

#endif
#endif
