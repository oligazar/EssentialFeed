//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Alexander on 8/4/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
