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
    
    init(_ object: T? = nil) {
        self.object = object
    }
}

extension WeakRef: FeedLoadingView where T: FeedLoadingView {
    func display(loading: Bool) {
        object?.display(loading: loading)
    }
}

extension WeakRef: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel: viewModel)
    }
}

final class FeedViewAdapter: FeedView {
    weak var feedController: FeedViewController?
    private let loader: ImageDataLoader
    
    init(loader: ImageDataLoader) {
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        feedController?.cellControllers = feed.map { model in
            let adapter = FeedImageLoaderPresentationAdapter<UIImage, WeakRef<FeedImageCellViewController>>(loader: loader, model: model)
            let view = FeedImageCellViewController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRef(view), model: model, transform: UIImage.init)
            return view
        }
    }
}

final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
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
            case let .success(feed):
                presenter?.didReceive(feed: feed)
            case let .failure(error):
                presenter?.didReceive(error: error)
            }
        }
    }
}

final class FeedImageLoaderPresentationAdapter<Image, View: FeedImageView>: FeedImageCellControllerDelegate where View.Image == Image {
    private let loader: ImageDataLoader
    private let model: FeedImage
    
    var presenter: FeedImagePresenter<Image, View>?
    
    private var task: ImageDataLoaderTask?
    
    init(loader: ImageDataLoader, model: FeedImage) {
        self.loader = loader
        self.model = model
    }
    
    func didRequestImage() {
        presenter?.didLoadingStarted()
        task = loader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didReceive(image: data)
            case let .failure(error):
                self?.presenter?.didReceive(error: error)
            }
        }
    }
    
    func didCancelRequestImage() {
        task?.cancel()
        task = nil
    }
}
