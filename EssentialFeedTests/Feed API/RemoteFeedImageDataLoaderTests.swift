//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 3/7/21.
//

import XCTest
import EssentialFeed

enum RemoteFeedImageDataLoaderResult {
    case failure(Error)
}

class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (RemoteFeedImageDataLoaderResult) -> Void) {
        client.get(from: url) { result in
            switch(result) {
            case let .failure(error):
                completion(.failure(error))
            case .success((_, _)):
                print("success, huh?")
            }
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_remoteFeedImageDataLoader_doesNotPerfomrAnyUrlRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = makeURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = makeURL()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_returnsErrorOnNetworkError() {
        let (sut, client) = makeSUT()
        let url = makeURL()
        let httpError = NSError(domain: "Http Error", code: 0)
        
        let expectation = expectation(description: "Wait for completion to finish")
        sut.loadImageData(from: url) { result in
            switch (result) {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError as NSError, httpError)
            }
            expectation.fulfill()
        }
        
        client.completeWith(error: httpError, at: 0)
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackMemoryLeaks(client)
        trackMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func makeURL() -> URL {
        return URL(string: "http://a-given-url.com")!
    }
    
    class HttpClientSpy: HTTPClient {
        
        typealias onRequestFinished = (HTTPClient.Result) -> Void
        
        var requests = [(URL, onRequestFinished)]()
        
        var requestedURLs: [URL] {
            return requests.map { $0.0 }
        }
        
        func completeWith(error: Error, at index: Int = 0) {
            let (_, completion) = requests[index]
            completion(.failure(error))
        }
        
        func get(from url: URL, completion: @escaping onRequestFinished) {
            requests.append((url, completion))
        }
    }
}
