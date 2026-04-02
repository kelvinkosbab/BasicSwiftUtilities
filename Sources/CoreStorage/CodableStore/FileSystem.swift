//
//  FileSystem.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - FileSystem

/// Abstracts file system operations for testability.
///
/// Provides methods for reading, writing, and deleting files, as well as creating directories
/// and checking file existence. Use ``ConcreteFileSystem`` for the real implementation.
protocol FileSystem: Sendable {

    /// Reads data from the file at the given URL.
    func read(contensOf url: URL, options: Data.ReadingOptions) throws -> Data

    /// Writes data to the file at the given URL.
    func write(data: Data, to url: URL, options: Data.WritingOptions) throws

    /// Creates a directory at the given URL.
    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws

    /// Deletes the file or directory at the given URL.
    func delete(at url: URL) throws

    /// Returns whether a file exists at the given path.
    func fileExists(atPath path: String) -> Bool
}

extension FileSystem {

    /// Returns whether a file exists at the given URL.
    func fileExists(atURL url: URL) -> Bool {
        return self.fileExists(atPath: url.path)
    }
}
