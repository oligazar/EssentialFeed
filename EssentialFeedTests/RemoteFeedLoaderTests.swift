//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alexander on 9/4/21.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    
}

class HttpClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
