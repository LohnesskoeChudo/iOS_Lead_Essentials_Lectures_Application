//
//  FeedUIComposer.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

public enum FeedUIComposer {
    public static func make(feedLoader: FeedLoader, imageDataLoader: ImageDataLoader) -> FeedViewController {
        let feedViewAdapter = FeedViewAdapter(loader: imageDataLoader)
        let proxyLoadingView = WeakRef<FeedRefreshViewController>()
        
        let presenter = FeedPresenter(feedLoader: feedLoader, feedView: feedViewAdapter, feedLoadingView: proxyLoadingView)
        
        let refreshViewController = FeedRefreshViewController(presenter: presenter)
        let feedTableViewController = FeedViewController(refreshController: refreshViewController)
        
        feedViewAdapter.feedController = feedTableViewController
        proxyLoadingView.object = refreshViewController
        return feedTableViewController
    }
}

class WeakRef<T: AnyObject> {
    weak var object: T?
}

extension WeakRef: FeedLoadingView where T: FeedLoadingView {
    func display(loading: Bool) {
        object?.display(loading: loading)
    }
}

final class FeedViewAdapter: FeedView {
    weak var feedController: FeedViewController?
    private let loader: ImageDataLoader
    
    init(loader: ImageDataLoader) {
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        feedController?.cellControllers = feed.map {
            let viewModel = FeedImageViewModel(image: $0, loader: loader, transform: UIImage.init)
            return FeedImageCellViewController(viewModel: viewModel)
        }
    }
}
