//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Alexander on 24/5/21.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var viewModel: FeedImageCellViewModel<UIImage>
    
    init(viewModel: FeedImageCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let view = binded(FeedImageCell())
        viewModel.loadImageData()
        return view
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    func binded(_ cell: FeedImageCell) -> UITableViewCell {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChanged = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
