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
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
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
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        // Arrange/Given
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)
        // Act/When
        sut.load()
        // Assert/Then
        XCTAssertNotNil(client.requestedURL)
    }
}
