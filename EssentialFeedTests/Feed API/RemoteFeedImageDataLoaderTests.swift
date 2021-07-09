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
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch(result) {
            case let .failure(error): task.complete(with: .failure(error))
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            }
        }
        return task
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_remoteFeedImageDataLoader_doesNotPerfomrAnyUrlRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://a-given-url.com")!
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://a-given-url.com")!
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Http Error", code: 0)
        
        expect(sut: sut, toCompleteWith: .failure(clientError)) {
            client.complete(with: clientError, at: 0)
        }
    }
    
    func test_loadImageDataFromURL_deliverInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = Data()
        
        expect(sut: sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyReceivedDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non empty data".utf8)
        
        expect(sut: sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHaveBeenDeallocated() {
        let client = HttpClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://any-given-url.com")!
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request util task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }
    
    func test_cancelLoadImageDataURLTask_doesNotDeliverResult() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        
        task.cancel()
        
        client.complete(withStatusCode: 400, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
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
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult)
            default: XCTFail("Expected \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    class HttpClientSpy: HTTPClient {
        
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        typealias onRequestFinished = (HTTPClient.Result) -> Void
        
        var requests = [(url: URL, completion: onRequestFinished)]()
        
        var requestedURLs: [URL] {
            return requests.map { $0.url }
        }
        
        var cancelledURLs = [URL]()
        
        func complete(with error: Error, at index: Int = 0) {
            let (_, completion) = requests[index]
            completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let (_, completion) = requests[index]
            
            let response = HTTPURLResponse(
                url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil
            )!
            
            completion(.success((data, response)))
        }
        
        func get(from url: URL, completion: @escaping onRequestFinished) -> HTTPClientTask {
            requests.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
    }
}
