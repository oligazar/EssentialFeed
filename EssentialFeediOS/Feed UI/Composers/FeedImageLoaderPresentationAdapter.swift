//
//  FeedImageLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Alexander on 2/6/21.
//

import EssentialFeed

final class FeedImageLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(feedImage: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = feedImage
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self = self else { return }
            
            if let data = (try? result.get()) {
                self.presenter?.didFinishLoadingImage(data, for: self.model)
            } else {
                self.presenter?.didFailedLoadingImage(for: self.model)
            }
        }
    }
    
    func cancelImageRequest() {
        task?.cancel()
    }
}
