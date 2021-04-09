//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alexander on 9/4/21.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HttpClient
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}
