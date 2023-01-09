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
    var cellControllers: [FeedImageCellViewController] = [] {
        didSet { tableView.reloadData() }
    }
    
    public convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
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
        cellControllers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellControllers[indexPath.row].view
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
        cellControllers[index].cancelPreload()
    }
    
    private func startTask(at index: Int) {
        cellControllers[index].preload()
    }
}
