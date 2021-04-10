//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 9/4/21.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        XCTAssertTrue(makeSUT().client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        // Arrange/Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        // Act/When
        sut.load()
        // Assert/Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        client.error = NSError(domain: "Test", code: 0)
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    // MARK: Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
    
    class HttpClientSpy: HttpClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            requestedURLs.append(url)
            if let error = error {
                completion(error)
            }
        }
    }
}
