//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Alexander on 8/4/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
