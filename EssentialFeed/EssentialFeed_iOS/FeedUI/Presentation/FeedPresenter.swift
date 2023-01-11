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
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView
    
    init (
        feedView: FeedView,
        feedLoadingView: FeedLoadingView
    ) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }
    
    func didStartLoading() {
        feedLoadingView.display(loading: true)
    }
    
    func didReceive(feed: [FeedImage]) {
        feedLoadingView.display(loading: false)
        feedView.display(feed: feed)
    }
    
    func didReceive(error: Error) {
        feedLoadingView.display(loading: false)
    }
}
