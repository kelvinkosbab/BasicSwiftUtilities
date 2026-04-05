//
//  FileSystemTests.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Testing
import Foundation
@testable import CoreStorage

// MARK: - ConcreteFileSystemTests

@Suite("ConcreteFileSystem", .serialized)
struct ConcreteFileSystemTests {

    private let fileSystem = ConcreteFileSystem()
    private let testDirectory = FileManager.default.temporaryDirectory
        .appending(path: "ConcreteFileSystemTests-\(UUID().uuidString)")

    @Test("Write and read data round-trips correctly")
    func writeAndRead() throws {
        let url = testDirectory.appending(path: "test.txt")
        try fileSystem.createDirectory(
            at: testDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let original = Data("hello world".utf8)
        try fileSystem.write(data: original, to: url, options: .atomic)

        let read = try fileSystem.read(contensOf: url, options: [])
        #expect(read == original)

        try fileSystem.delete(at: testDirectory)
    }

    @Test("fileExists returns true for existing file")
    func fileExistsTrue() throws {
        let url = testDirectory.appending(path: "exists.txt")
        try fileSystem.createDirectory(
            at: testDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try fileSystem.write(data: Data("data".utf8), to: url, options: .atomic)

        #expect(fileSystem.fileExists(atPath: url.path))

        try fileSystem.delete(at: testDirectory)
    }

    @Test("fileExists returns false for missing file")
    func fileExistsFalse() {
        let path = testDirectory.appending(path: "nonexistent.txt").path
        #expect(!fileSystem.fileExists(atPath: path))
    }

    @Test("Delete removes a file")
    func deleteFile() throws {
        let url = testDirectory.appending(path: "deleteme.txt")
        try fileSystem.createDirectory(
            at: testDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try fileSystem.write(data: Data("data".utf8), to: url, options: .atomic)
        #expect(fileSystem.fileExists(atPath: url.path))

        try fileSystem.delete(at: url)
        #expect(!fileSystem.fileExists(atPath: url.path))

        try fileSystem.delete(at: testDirectory)
    }

    @Test("createDirectory creates nested directories")
    func createNestedDirectory() throws {
        let nested = testDirectory.appending(path: "a/b/c")
        try fileSystem.createDirectory(
            at: nested,
            withIntermediateDirectories: true,
            attributes: nil
        )
        #expect(fileSystem.fileExists(atPath: nested.path))

        try fileSystem.delete(at: testDirectory)
    }

    @Test("Read from nonexistent file throws")
    func readNonexistentThrows() {
        let url = testDirectory.appending(path: "nope.txt")
        #expect(throws: (any Error).self) {
            _ = try fileSystem.read(contensOf: url, options: [])
        }
    }

    @Test("fileExists at URL extension works")
    func fileExistsAtURL() throws {
        let url = testDirectory.appending(path: "urltest.txt")
        try fileSystem.createDirectory(
            at: testDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try fileSystem.write(data: Data("data".utf8), to: url, options: .atomic)

        #expect(fileSystem.fileExists(atURL: url))
        #expect(!fileSystem.fileExists(atURL: testDirectory.appending(path: "missing.txt")))

        try fileSystem.delete(at: testDirectory)
    }
}
