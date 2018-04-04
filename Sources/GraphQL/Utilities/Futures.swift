//
//  DictionaryFuture.swift
//  GraphQL
//
//  Created by Jeff Seibert on 3/9/18.
//

import Foundation
import NIO

/// Callback for accepting a result.
typealias FutureResultCallback<T> = (FutureResult<T>) -> ()

/// A future result type.
/// Concretely implemented by `Future<T>`
protocol FutureType {
    /// This future's expectation.
    associatedtype Expectation
    
    /// This future's result type.
    typealias Result = FutureResult<Expectation>
    
    /// Adds a new awaiter to this `Future` that will be called when the result is ready.
    func addAwaiter(callback: @escaping FutureResultCallback<Expectation>)
}

extension EventLoopFuture: FutureType {
    /// See `FutureType`.
    typealias Expectation = T
    
    /// See `FutureType`.
    func addAwaiter(callback: @escaping (FutureResult<T>) -> ()) {
        self.map { (result: T) -> T in
            callback(.success(result))
            return result
        }.whenFailure { error in
            callback(.error(error))
        }
    }
}

// Indirect so futures can be nested.
indirect enum FutureResult<T> {
    case error(Error)
    case success(T)
    
    /// Returns the result error or `nil` if the result contains expectation.
    var error: Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
    /// Returns the result expectation or `nil` if the result contains an error.
    var result: T? {
        switch self {
        case .success(let expectation):
            return expectation
        default:
            return nil
        }
    }
    
    /// Throws an error if this contains an error, returns the Expectation otherwise
    func unwrap() throws -> T {
        switch self {
        case .success(let data):
            return data
        case .error(let error):
            throw error
        }
    }
}


extension Dictionary where Value: FutureType {
    func flatten(on worker: EventLoopGroup) -> EventLoopFuture<[Key: Value.Expectation]> {
        var elements: [Key: Value.Expectation] = [:]
        
        guard self.count > 0 else {
            return worker.next().newSucceededFuture(result: elements)
        }
        
        let promise: EventLoopPromise<[Key: Value.Expectation]> = worker.next().newPromise()
        elements.reserveCapacity(self.count)
        
        for (key, value) in self {
            value.addAwaiter { result in
                switch result {
                case .error(let error): promise.fail(error: error)
                case .success(let expectation):
                    elements[key] = expectation
                    
                    if elements.count == self.count {
                        promise.succeed(result: elements)
                    }
                }
            }
        }
        
        return promise.futureResult
    }
}

extension Collection where Element: FutureType {
    /// Flattens an array of futures into a future with an array of results.
    /// - note: the order of the results will match the order of the futures in the input array.
    func flatten(on group: EventLoopGroup) -> EventLoopFuture<[Element.Expectation]> {
        var elements: [Element.Expectation] = []
        
        let promise: EventLoopPromise<[Element.Expectation]> = group.next().newPromise()
        guard count > 0 else {
            promise.succeed(result: elements)
            return promise.futureResult
        }
        
        elements.reserveCapacity(self.count)
        
        for element in self {
            element.addAwaiter { result in
                switch result {
                case .error(let error): promise.fail(error: error)
                case .success(let expectation):
                    elements.append(expectation)
                    
                    if elements.count == self.count {
                        promise.succeed(result: elements)
                    }
                }
            }
        }
        
        return promise.futureResult
    }
}

extension Collection where Element == EventLoopFuture<Void> {
    /// Flattens an array of void futures into a single one.
    func flatten(on worker: EventLoopGroup) -> EventLoopFuture<Void> {
        let flatten: EventLoopFuture<[Void]> = self.flatten(on: worker)
        return flatten.map { _ in return }
    }
}

