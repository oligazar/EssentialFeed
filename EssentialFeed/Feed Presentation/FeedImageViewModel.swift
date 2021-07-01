//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Alexander on 1/7/21.
//

import Foundation

public struct FeedImageViewModel<Image: Equatable>: Equatable {
    
    public let location: String?
    public let description: String?
    public let image: Image?
    public let isImageLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
