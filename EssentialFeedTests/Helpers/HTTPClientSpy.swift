//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Alexander on 9/7/21.
//

import Foundation
import EssentialFeed

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
