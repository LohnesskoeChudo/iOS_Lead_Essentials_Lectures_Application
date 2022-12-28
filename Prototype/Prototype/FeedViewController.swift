//
//  FeedViewController.swift
//  Prototype
//
//  Created by Василий Клецкин on 27.12.2022.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    
    var items = [FeedImageViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Essential Feed"
        reload()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else { return .init() }
        cell.configure(with: items[indexPath.row])
        return cell
    }
    
    @IBAction func reload() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl?.endRefreshing()
            guard self.items.isEmpty else { return }
            self.items = FeedImageViewModel.prototypeFeed
            self.tableView.reloadData()
        }
    }
}

extension FeedCell {
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        
        fade(in: UIImage(named: model.imageName))
    }
}
