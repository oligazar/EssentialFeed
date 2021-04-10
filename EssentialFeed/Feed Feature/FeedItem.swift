//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Alexander on 8/4/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
