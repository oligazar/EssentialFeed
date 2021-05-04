//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Alexander on 4/5/21.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(images):
                XCTAssertEqual(images, [], "Expected empty feed")
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let bundle = Bundle.init(for: CoreDataFeedStore.self)
        let coreDataStore = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let loader = LocalFeedLoader(store: coreDataStore, currentDate: Date.init)
        trackMemoryLeaks(coreDataStore, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        return loader
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

}
