//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Alexander on 21/4/21.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(
        id: UUID(), description: "any", location: "any", url: anyURL()
    )
}

internal func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let local = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (items, local)
}

extension Date {
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
