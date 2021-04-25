//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Alexander on 11/4/21.
//

import Foundation

public enum HTTPClienResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    func get(from url: URL, completion: @escaping (HTTPClienResult) -> Void)
}
