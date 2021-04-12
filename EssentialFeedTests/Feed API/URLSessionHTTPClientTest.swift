//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Alexander on 12/4/21.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    internal init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromUrl_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    // MARK: Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override init() {}
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}
    }
}
