//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Alexander on 10/7/21.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    return data.map { .success($0) } ?? .failure(Error.notFound)
                })
        }
        return task
    }
    
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { _ in }
    }
}
