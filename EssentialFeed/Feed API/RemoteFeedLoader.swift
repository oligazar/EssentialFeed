//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Alexander on 9/4/21.
//

import Foundation

public enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HttpClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map { $0.item}))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
    
    var item: FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}

// Hint how to implement decodable
// extension FeedItem: Decodable {
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case description
//        case location
//        case imageURL = "image"
//    }
//}
