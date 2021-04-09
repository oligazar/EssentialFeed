//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 9/4/21.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    let client: HttpClient
    let url: URL
    
    init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HttpClient {
    
    func get(from url: URL)
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        // Arrange/Given
        let url = URL(string: "https://a-given-url.com")!
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        // Act/When
        sut.load()
        // Assert/Then
        XCTAssertEqual(client.requestedURL, url)
    }
}
