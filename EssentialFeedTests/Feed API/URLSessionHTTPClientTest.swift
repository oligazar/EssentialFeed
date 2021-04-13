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
        let task = session.dataTask(with: url) { _, _, _ in }
        task.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromUrl_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = FakeURLSessionDataTaskSpy()
        session.stub(url: url, with: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: Helpers
    
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        
        override init() {}
        
        func stub(url: URL, with task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override init() {}
//        override func resume() {}
    }
    
    private class FakeURLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override init() {}
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
