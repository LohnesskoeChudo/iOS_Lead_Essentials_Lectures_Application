//
//  FeedPresenter.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(loading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView
    
    init (
        feedLoader: FeedLoader,
        feedView: FeedView,
        feedLoadingView: FeedLoadingView
    ) {
        self.feedLoader = feedLoader
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }
    
    func load() {
        feedLoadingView.display(loading: true)
        feedLoader.load() { [weak self] result in
            self?.feedLoadingView.display(loading: false)
            if case let .success(feed) = result {
                self?.feedView.display(feed: feed)
            }
        }
    }
}
