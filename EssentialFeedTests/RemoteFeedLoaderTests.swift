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
        HttpClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HttpClient {
    static var shared = HttpClient()
    
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        // Arrange/Given
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
        // Act/When
        sut.load()
        // Assert/Then
        XCTAssertNotNil(client.requestedURL)
    }
}
