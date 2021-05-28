//
//  FeedImageCellPresenter.swift
//  EssentialFeediOS
//
//  Created by Alexander on 27/5/21.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil, isImageLoading: true,
            shouldRetry: false
        ))
    }
    
    func didFinishLoadingImage(_ data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFailedLoadingImage(for: model)
        }
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: image,
            isImageLoading: false,
            shouldRetry: false
        ))
    }
    
    func didFailedLoadingImage(for model: FeedImage) {
        view.display(FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: nil,
            isImageLoading: false,
            shouldRetry: true
        ))
    }
}
