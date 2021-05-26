//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Alexander on 25/5/21.
//

import Foundation
import EssentialFeed

final class FeedImageCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var imageTransformer: (Data) -> Image?
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, converter: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = converter
    }
    
    var description: String? {
        return model.description
    }
    
    var location: String? {
        return model.location
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChanged: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChanged?(true)
        onShouldRetryImageLoadStateChange?(false)
        self.loadImageData { result in
            if let image = (try? result.get()).flatMap(self.imageTransformer) {
                self.onImageLoad?(image)
            } else {
                self.onShouldRetryImageLoadStateChange?(true)
            }
            self.onImageLoadingStateChanged?(false)
        }
    }
    
    func loadImageData(completion: @escaping ((FeedImageDataLoader.Result) -> Void) = { _ in}) {
        task = imageLoader.loadImageData(from: model.url, completion: completion)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
    }
}
