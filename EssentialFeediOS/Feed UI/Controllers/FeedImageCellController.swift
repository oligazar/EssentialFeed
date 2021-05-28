//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Alexander on 24/5/21.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func cancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    typealias Image = UIImage
    
    private lazy var cell = FeedImageCell()
    private let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        cell.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = model.image
        cell.feedImageContainer.isShimmering = model.isImageLoading
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.cancelImageRequest()
    }
}
