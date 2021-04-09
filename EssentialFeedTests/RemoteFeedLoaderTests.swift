//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 9/4/21.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    func load() {
        HttpClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HttpClient {
    static var shared = HttpClient()
    
    func get(from url: URL) {
        
    }
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClientSpy()
        HttpClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        // Arrange/Given
        let client = HttpClientSpy()
        HttpClient.shared = client
        let sut = RemoteFeedLoader()
        // Act/When
        sut.load()
        // Assert/Then
        XCTAssertNotNil(client.requestedURL)
    }
}
