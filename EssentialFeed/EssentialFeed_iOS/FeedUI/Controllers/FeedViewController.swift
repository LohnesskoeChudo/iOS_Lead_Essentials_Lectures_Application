//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 28.12.2022.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshViewController?
    private var imageDataLoader: ImageDataLoader?
    private var tasks: [UUID: ImageDataLoaderTask] = [:]
    private var images: [FeedImage] = [] {
        didSet { tableView.reloadData() }
    }
    
    public convenience init(feedLoader: FeedLoader, imageDataLoader: ImageDataLoader) {
        self.init()
        self.imageDataLoader = imageDataLoader
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        refreshController?.onImagesReceived = { [weak self] images in
            self?.images = images
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        load()
    }
    
    @objc private func load() {
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let image = images[indexPath.row]
        let cell = FeedImageCell()
        cell.descriptionLabel.text = image.description
        cell.locationLabel.text = image.location
        cell.locationContainer.isHidden = image.location == nil
        cell.imageContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        let loadImageData = { [weak self, weak cell] in
            let task = self?.imageDataLoader?.loadImageData(from: image.url) { result in
                cell?.imageContainer.stopShimmering()
                if let data = try? result.get() {
                    let image = UIImage(data: data)
                    cell?.feedImageView.image = image
                    cell?.retryButton.isHidden = image != nil
                } else {
                    cell?.retryButton.isHidden = false
                }
            }
            if let task = task {
                self?.tasks[image.id] = task
            }
        }
        
        loadImageData()
        cell.onRetry = loadImageData
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(at: indexPath.row)
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startTask(at: indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for row in indexPaths.map({ $0.row }) {
            startTask(at: row)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for row in indexPaths.map({ $0.row }) {
            cancelTask(at: row)
        }
    }
    
    private func cancelTask(at index: Int) {
        let image = images[index]
        tasks[image.id]?.cancel()
        tasks[image.id] = nil
    }
    
    private func startTask(at index: Int) {
        let image = images[index]
        tasks[image.id] = imageDataLoader?.loadImageData(from: image.url) { _ in }
    }
}