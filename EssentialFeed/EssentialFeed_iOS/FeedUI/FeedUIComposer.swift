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
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshViewController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedTableViewController = FeedViewController(refreshController: refreshViewController)
        feedViewModel.onFeedReceived = adaptFeedToCellControllers(loader: imageDataLoader, feedController: feedTableViewController)
        return feedTableViewController
    }
    
    private static func adaptFeedToCellControllers(loader: ImageDataLoader, feedController: FeedViewController) -> ([FeedImage]) -> Void {
        return { [weak feedController] feed in
            feedController?.cellControllers = feed.map {
                let viewModel = FeedImageViewModel(image: $0, loader: loader, transform: UIImage.init)
                return FeedImageCellViewController(viewModel: viewModel)
            }
        }
    }
}
