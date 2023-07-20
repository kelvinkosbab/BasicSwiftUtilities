//
//  LongRunningTaskOrchestrator.swift
//
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)
#if !os(watchOS)

import UIKit

// MARK: - Types

/// A function to call when the long running task is done working after being registered by the `LongRunningTaskOrchestrator`.
public typealias DoneWorking = () -> Void

// MARK: - LongRunningTaskOrchestrator

/// Helps orchestrate and register tasks that should continue if the app enters the background.
///
/// For more information see [`UIApplication:beginBackgroundTask`](https://developer.apple.com/documentation/uikit/uiapplication/1623051-beginbackgroundtask).
public struct LongRunningTaskOrchestrator {
    
    // MARK: - Singleton
    
    public static let shared = LongRunningTaskOrchestrator()
    
    // MARK: - Properties
    
    private let workQueue = DispatchQueue(label: "LongRunningTaskOrchestrator")
    private let logger: Loggable = SubsystemCategoryLogger(
        subsystem: "LongRunningTaskOrchestrator",
        category: "RegisterTask"
    )
    
    // MARK: - Result
    
    /// Defiens the various ways that a long running task can finish.
    public enum Result {
        
        /// The OS cancelled the task because the it took to long.
        case expiredByOS
        
        /// The task was cancelled because it timed out.
        case timeout
        
        /// The task completed.
        case completed
    }
    
    // MARK: - Register
    
    /// Registers the start of a long running task with a custom name that should continue if the app enters the background.
    ///
    /// For more information see [`UIApplication:beginBackgroundTask`](https://developer.apple.com/documentation/uikit/uiapplication/1623051-beginbackgroundtask).
    ///
    /// - Parameter taskName: The name to display in the debugger when viewing the background task. If you
    /// specify nil for this parameter, the method generates a name based on the name of the calling function or method.
    /// - Parameter timeout: The timeout for the long running task in seconds.
    ///
    /// - Returns: A function that should be called as soon as the background task completes.
    public func register(
        taskName: String,
        timeout: Double = 60
    ) -> DoneWorking {
        let info = ProcessInfo()
        let start = info.systemUptime
        var backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        self.logger.info("\(taskName): Registering task")
        
        func endTask(result: Result) {
            self.workQueue.sync {
                if backgroundTaskId == .invalid {
                    self.logger.info("\(taskName): Stopping duplicate task")
                } else {
                    self.logger.info("\(taskName): Task has completed with \(String(describing: result)). Task duration = \(Int(info.systemUptime - start))s.")
                    UIApplication.shared.endBackgroundTask(backgroundTaskId)
                    backgroundTaskId = .invalid
                }
            }
        }
        
        let timeoutBlock = DispatchWorkItem {
            self.logger.info("\(taskName): Task never responded and has timed out after \(Int(info.systemUptime - start))s. Releasing task.")
            endTask(result: .timeout)
        }
        
        // Method the caller calls to signal the long running task has completed.
        func done() {
            self.logger.info("\(taskName): Caller signaled task has completed. Releasing task.")
            endTask(result: .completed)
            timeoutBlock.cancel()
        }
        
        // Registers the task with the OS.
        DispatchQueue.global().async {
            backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "LongRunningTaskOrchestrator.\(taskName)") {
                
                // A handler to be called shortly before the app’s remaining background time
                // reaches 0. Use this handler to clean up and mark the end of the background
                // task. Failure to end the task explicitly will result in the termination of
                // the app. The system calls the handler synchronously on the main thread,
                // blocking the app’s suspension momentarily.
                self.logger.info("\(taskName): OS is expiring the task. Releasing task.")
                endTask(result: .expiredByOS)
                timeoutBlock.cancel()
            }
            
            // Check if the task was denied by the OS.
            if backgroundTaskId == .invalid {
                self.logger.info("\(taskName): Task execution denied")
            }
        }
        
        // Set up a manual expiration if the caller takes too long to call `done`. Over time taking too
        // long will get the app penalized.
        DispatchQueue.global().asyncAfter(
            deadline: .now() + timeout,
            execute: timeoutBlock
        )
        
        return done
    }
}

#endif
#endif
