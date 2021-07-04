//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 3/7/21.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch(result) {
            case let .failure(error): completion(.failure(error))
            default: break
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
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Http Error", code: 0)
        
        expect(sut: sut, toCompleteWith: .failure(clientError)) {
            client.completeWith(error: clientError, at: 0)
        }
    }
    
    // MARK: helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackMemoryLeaks(client)
        trackMemoryLeaks(sut)
        return (sut, client)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "http://a-given-url.com")!
        
        let exp = expectation(description: "Wait for completion to finish")
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default: break
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func makeURL() -> URL {
        return URL(string: "http://a-given-url.com")!
    }
    
    class HttpClientSpy: HTTPClient {
        
        typealias onRequestFinished = (HTTPClient.Result) -> Void
        
        var requests = [(url: URL, completion: onRequestFinished)]()
        
        var requestedURLs: [URL] {
            return requests.map { $0.url }
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
