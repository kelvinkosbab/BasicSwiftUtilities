//
//  ConcreteFileSystem.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

/// The production ``FileSystem`` implementation backed by `Foundation` APIs.
final class ConcreteFileSystem: FileSystem, Sendable {

    func read(
        contensOf url: URL,
        options: Data.ReadingOptions
    ) throws -> Data {
        return try Data(contentsOf: url, options: options)
    }

    func write(
        data: Data,
        to url: URL,
        options: Data.WritingOptions
    ) throws {
        try data.write(to: url, options: options)
    }

    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: createIntermediates,
            attributes: attributes
        )
    }

    func delete(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}
