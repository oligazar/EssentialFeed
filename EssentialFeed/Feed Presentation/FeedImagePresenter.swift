//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Alexander on 1/7/21.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image: Equatable
    
    func display(_ model: FeedImageViewModel<Image>)
}

public class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil, isImageLoading: true,
            shouldRetry: false
        ))
    }
    
    public func didFinishLoadingImage(_ data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: image,
            isImageLoading: false,
            shouldRetry: false
        ))
    }
    
    public func didFailedLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil,
            isImageLoading: false,
            shouldRetry: true
        ))
    }
}
