//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Alexander on 24/5/21.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.imageView?.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.preload { [weak cell] result in
                if let data = try? result.get(), let image = UIImage(data: data) {
                    cell?.feedImageView.image = image
                } else {
                    cell?.feedImageRetryButton.isHidden = false
                }
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload(completion: @escaping ((FeedImageDataLoader.Result) -> Void) = { _ in}) {
        task = imageLoader.loadImageData(from: model.url, completion: completion)
    }
    
    deinit {
        task?.cancel()
    }
}
