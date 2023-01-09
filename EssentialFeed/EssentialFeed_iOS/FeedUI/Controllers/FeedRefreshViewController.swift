//
//  FeedRefreshViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    private let feedLoader: FeedLoader
    let view = UIRefreshControl()
    
    var onImagesReceived: (([FeedImage]) -> ())?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
        super.init()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load() { [weak self] images in
            self?.view.endRefreshing()
            if case let .success(images) = images {
                self?.onImagesReceived?(images)
            }
        }
    }
}
