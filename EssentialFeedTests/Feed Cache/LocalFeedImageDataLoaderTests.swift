//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 10/7/21.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    
    func retrieve(dataForURL url: URL)
    
}

class LocalFeedImageDataLoader: FeedImageDataLoader {
    struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_loadImageData_doesNotMessageStoreUponCreateion() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    
    func test_loadImageData_requestsDataFromStore() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        var receivedMessages = [Message]()
        
        func retrieve(dataForURL url: URL) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}
