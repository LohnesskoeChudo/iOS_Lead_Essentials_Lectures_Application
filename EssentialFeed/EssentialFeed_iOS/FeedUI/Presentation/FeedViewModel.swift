//
//  FeedViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private let feedLoader: FeedLoader
    
    var onLoadingStateChanged: Observer<Bool>?
    var onFeedReceived: Observer<[FeedImage]>?
    
    init (feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func load() {
        onLoadingStateChanged?(true)
        feedLoader.load() { [weak self] result in
            self?.onLoadingStateChanged?(false)
            if case let .success(images) = result {
                self?.onFeedReceived?(images)
            }
        }
    }
}
