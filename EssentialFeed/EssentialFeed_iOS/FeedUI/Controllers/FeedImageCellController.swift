//
//  FeedCellController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

final class FeedImageCellViewController {
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    var view: UITableViewCell {
        let cell = FeedImageCell()
        bind(cell)
        configure(cell)
        viewModel.loadImageData()
        return cell
    }
    
    private func configure(_ cell: FeedImageCell) {
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.locationContainer.isHidden = !viewModel.needToPresentLocation
        cell.imageContainer.startShimmering()
        cell.retryButton.isHidden = true
    }
    
    private func bind(_ cell: FeedImageCell) {
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoaded = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onShouldRetryStateChanged = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        viewModel.onLoadingStateChanged = { [weak cell] isLoading in
            if isLoading {
                cell?.imageContainer.startShimmering()
            } else {
                cell?.imageContainer.stopShimmering()
            }
        }
    }
    
    func cancelPreload() {
        viewModel.cancelPreload()
    }
    
    func preload() {
        viewModel.preload()
    }
    
    deinit {
        cancelPreload()
    }
}
