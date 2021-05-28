//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alexander on 28/5/21.
//

import Foundation

struct FeedImageViewModel<Image> {
    
    let location: String?
    let description: String?
    let image: Image?
    let isImageLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
