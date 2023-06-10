//
//  FileSystem.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - FileSystem

/// A shim `FileSystem` protocol that allows mocking of the read and write `Data` APIs.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
protocol FileSystem {
    
    /// See `Data(url:options:)`
    func read(contensOf url: URL, options: Data.ReadingOptions) throws -> Data
    
    /// See `Data.write(url:options:)`
    func write(data: Data, to url: URL, options: Data.WritingOptions) throws
    
    /// See `FileManager.createDirectory(url:createIntermediates:attributes:)`
    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws
    
    /// See `FileManager.removeItem(url:)`
    func delete(at url: URL) throws
    
    /// See `FileManager.fileExists(path:)`
    func fileExists(atPath path: String) -> Bool
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension FileSystem {
    
    /// A utility for checking file existence via URL rather than path String.
    func fileExists(atURL url: URL) -> Bool {
        return self.fileExists(atPath: url.path)
    }
}
