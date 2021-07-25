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
        presenter?.didStartLoadingImageData(for: model)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self = self else { return }
            
            switch (result) {
            case let .success(data):
                self.presenter?.didFinishLoadingImageData(with: data, for: self.model)
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, for: self.model)
            }
        }
    }
    
    func cancelImageRequest() {
        task?.cancel()
    }
}
