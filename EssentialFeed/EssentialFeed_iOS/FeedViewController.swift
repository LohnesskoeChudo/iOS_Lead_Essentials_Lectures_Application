//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 28.12.2022.
//

import UIKit
import EssentialFeed

public protocol ImageDataLoader {
    func loadImageData(from url: URL)
}

public final class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageDataLoader: ImageDataLoader?
    private var images: [FeedImage] = []
    
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
        imageDataLoader?.loadImageData(from: image.url)
        return cell
    }
}
