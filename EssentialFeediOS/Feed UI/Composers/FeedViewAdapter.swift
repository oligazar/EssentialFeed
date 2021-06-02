//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Alexander on 2/6/21.
//

import UIKit
import EssentialFeed

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader

    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let imageAdapter = FeedImageLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(feedImage: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: imageAdapter)
        
            imageAdapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            
            return view
        }
    }
}
