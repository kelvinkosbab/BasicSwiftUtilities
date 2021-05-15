//
//  ThreadSafe.swift
//  
//  Copyright © 2021 Kozinga. All rights reserved.
//

import Foundation

// MARK: - ThreadSafe

public protocol ThreadSafe {
    var concurrentQueue: DispatchQueue { get }
}

public extension ThreadSafe {
    
    func concurrentlyRead<T>(_ block: (() -> T)) -> T {
        return self.concurrentQueue.sync {
            block()
        }
    }
    
    func exclusivelyWrite(_ block: @escaping (() -> Void)) {
        self.concurrentQueue.async(flags: .barrier) {
            block()
        }
    }
}

// MARK: - ThreadSafeDictionary

public class ThreadSafeDictionary<T: Hashable, U> : ThreadSafe {
    
    public let concurrentQueue: DispatchQueue = DispatchQueue(label: UUID().uuidString, attributes: .concurrent)
    private var dictionary: [T : U] = [:]
    
    public init() {}
    
    public subscript(key: T) -> U? {
        get {
            return self.concurrentlyRead { () -> U? in
                return self.dictionary[key]
            }
        }
        set(value) {
            self.exclusivelyWrite {
                self.dictionary[key] = value
            }
        }
    }
    
    public var values: [U] {
        return self.concurrentlyRead { () -> [U] in
            return self.dictionary.values.map { value -> U in
                return value
            }
        }
    }
    
    public func removeValue(forKey key: T) {
        self.exclusivelyWrite {
            self.dictionary.removeValue(forKey: key)
        }
    }
    
    public func removeAll() {
        self.exclusivelyWrite {
            self.dictionary.removeAll()
        }
    }
}

// MARK: - ThreadSafeSet

public class ThreadSafeSet<T: Hashable> : ThreadSafe {
    
    public let concurrentQueue: DispatchQueue = DispatchQueue(label: UUID().uuidString, attributes: .concurrent)
    private var set: Set<T> = Set()
    private let logger = Logger(category: "ThreadSafeSet.\(String(describing: T.self))")
    
    public init(_ set: Set<T> = Set()) {
        self.exclusivelyWrite {
            self.set = set
        }
    }
    
    public convenience init(_ array: Array<T>) {
        self.init(Set(array))
    }
    
    public func contains(_ member: T) -> Bool {
        return self.concurrentlyRead { () -> Bool in
            return self.set.contains(member)
        }
    }
    
    public func insert(_ newMember: T) {
        self.exclusivelyWrite {
            self.set.insert(newMember)
        }
    }
    
    public func remove(_ member: T) {
        self.exclusivelyWrite {
            self.set.remove(member)
        }
    }
    
    public func update(with member: T) {
        self.exclusivelyWrite {
            self.set.update(with: member)
        }
    }
    
    public var value: Set<T> {
        return self.concurrentlyRead { () -> Set<T> in
            return self.set
        }
    }
    
    public func contains(where check: (_ member: T) throws -> Bool) -> Bool {
        return self.concurrentlyRead { () -> Bool in
            do {
                return try self.set.contains(where: check)
            } catch {
                self.logger.error("Failed contains:where. \(error.localizedDescription)")
                return false
            }
        }
    }
    
    public func first(where check: (_ member: T) throws -> Bool) -> T? {
        return self.concurrentlyRead { () -> T? in
            do {
                return try self.set.first(where: check)
            } catch {
                self.logger.error("Failed first:where. \(error.localizedDescription)")
                return nil
            }
        }
    }
}

// MARK: - ThreadSafeArray

public class ThreadSafeArray<T> : ThreadSafe {
    
    public let concurrentQueue: DispatchQueue = DispatchQueue(label: UUID().uuidString, attributes: .concurrent)
    private var array: [T] = []
    private let logger = Logger(category: "ThreadSafeArray.\(String(describing: T.self))")
    
    public init() {}
    
    public subscript(index: Int) -> T? {
        get {
            return self.concurrentlyRead { () -> T? in
                
                guard index >= 0 && index < self.array.count else {
                    self.logger.error("Invalid index \(index)")
                    return nil
                }
                
                return self.array[index]
            }
        }
        set(value) {
            
            guard let value = value else {
                self.logger.error("Cannot set array element to nil. Do nothing.")
                return
            }
            
            self.exclusivelyWrite {
                self.array[index] = value
            }
        }
    }
}
