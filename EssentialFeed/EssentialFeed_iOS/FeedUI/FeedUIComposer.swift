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
        
        let presenter = FeedPresenter(feedView: feedViewAdapter, feedLoadingView: proxyLoadingView)
        let loaderAdapter = FeedLoaderPresentationAdapter(loader: feedLoader, presenter: presenter)
        
        let refreshViewController = FeedRefreshViewController(delegate: loaderAdapter)
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

final class FeedLoaderPresentationAdapter: FeedLoadingViewDelegate {
    private let loader: FeedLoader
    private let presenter: FeedPresenter
    
    init(loader: FeedLoader, presenter: FeedPresenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoading()
        loader.load() { [weak presenter] result in
            switch result {
            case let .success(feed): presenter?.didReceive(feed: feed)
            case let .failure(error): presenter?.didReceive(error: error)
            }
        }
    }
}
