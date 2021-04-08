//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Alexander on 8/4/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
