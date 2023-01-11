//
//  FeedCellController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelRequestImage()
}

final class FeedImageCellViewController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private let cell = FeedImageCell()
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    var view: UITableViewCell {
        configure(cell)
        delegate.didRequestImage()
        return cell
    }
    
    private func configure(_ cell: FeedImageCell) {
        cell.onRetry = delegate.didRequestImage
        cell.imageContainer.startShimmering()
        cell.retryButton.isHidden = true
    }
    
    func display(viewModel: FeedImageViewModel<UIImage>) {
        cell.feedImageView.image = viewModel.image
        cell.retryButton.isHidden = !viewModel.shouldRetry
        cell.locationContainer.isHidden = !viewModel.needToPresentLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        if viewModel.isLoading {
            cell.imageContainer.startShimmering()
        } else {
            cell.imageContainer.stopShimmering()
        }
    }
    
    func cancelPreload() {
        delegate.didCancelRequestImage()
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    deinit {
        cancelPreload()
    }
}
