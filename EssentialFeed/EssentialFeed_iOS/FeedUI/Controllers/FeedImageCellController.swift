//
//  FeedCellController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

final class FeedImageCellViewController {
    private let image: FeedImage
    private let imageDataLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    
    init(image: FeedImage, imageDataLoader: ImageDataLoader) {
        self.image = image
        self.imageDataLoader = imageDataLoader
    }
    
    var view: UITableViewCell {
        let cell = FeedImageCell()
        cell.descriptionLabel.text = image.description
        cell.locationLabel.text = image.location
        cell.locationContainer.isHidden = image.location == nil
        cell.imageContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        cell.onRetry = { [weak cell] in
            guard let cell = cell else { return }
            self.reloadImageData(for: cell)
        }

        reloadImageData(for: cell)
        return cell
    }
    
    private func reloadImageData(for cell: FeedImageCell) {
        task = imageDataLoader.loadImageData(from: image.url) { [weak cell] result in
            cell?.imageContainer.stopShimmering()
            if let data = try? result.get() {
                let image = UIImage(data: data)
                cell?.feedImageView.image = image
                cell?.retryButton.isHidden = image != nil
            } else {
                cell?.retryButton.isHidden = false
            }
        }
    }
    
    func cancelPreload() {
        task?.cancel()
    }
    
    func preload() {
        task = imageDataLoader.loadImageData(from: image.url) { _ in }
    }
    
    deinit {
        cancelPreload()
    }
}
