//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 28.12.2022.
//

import UIKit
import EssentialFeed

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageDataLoader: ImageDataLoader?
    private var images: [FeedImage] = []
    private var tasks: [UUID: ImageDataLoaderTask] = [:]
    
    public convenience init(feedLoader: FeedLoader, imageDataLoader: ImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageDataLoader = imageDataLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load() { [weak self] images in
            self?.refreshControl?.endRefreshing()
            if case let .success(images) = images {
                self?.images = images
                self?.tableView.reloadData()
            }
        }
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
        let task = imageDataLoader?.loadImageData(from: image.url) { result in
            cell.imageContainer.stopShimmering()
            if let data = try? result.get() {
                cell.feedImageView.image = UIImage(data: data)
            }
        }
        if let task = task {
            tasks[image.id] = task
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        let task = tasks[image.id]
        task?.cancel()
        tasks[image.id] = nil
    }
}
