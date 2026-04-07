//
//  LongRunningTaskOrchestrator.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

public import UIKit

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
        subsystem: "LongRunningTaskOrchestrator",
        category: "RegisterTask"
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
        let info = ProcessInfo()
        let start = info.systemUptime
        let logger = self.logger
        var backgroundTaskId = UIBackgroundTaskIdentifier.invalid

        logger.info("\(taskName): Registering task")

        @MainActor
        func endTask(result: Result) {
            if backgroundTaskId == .invalid {
                logger.info("\(taskName): Stopping duplicate task")
            } else {
                logger.info("\(taskName): Task has completed with \(String(describing: result)). Task duration = \(Int(info.systemUptime - start))s.")
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
                backgroundTaskId = .invalid
            }
        }

        let timeoutTask = DispatchWorkItem { @MainActor in
            logger.info("\(taskName): Task never responded and has timed out after \(Int(info.systemUptime - start))s. Releasing task.")
            endTask(result: .timeout)
        }

        @MainActor
        func done() {
            logger.info("\(taskName): Caller signaled task has completed. Releasing task.")
            endTask(result: .completed)
            timeoutTask.cancel()
        }

        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "LongRunningTaskOrchestrator.\(taskName)") {
            logger.info("\(taskName): OS is expiring the task. Releasing task.")
            endTask(result: .expiredByOS)
            timeoutTask.cancel()
        }

        if backgroundTaskId == .invalid {
            logger.info("\(taskName): Task execution denied")
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeout,
            execute: timeoutTask
        )

        return done
    }
}

#endif
#endif
