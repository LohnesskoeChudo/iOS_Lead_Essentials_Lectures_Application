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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FeedImageViewModel.prototypeFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else { return .init() }
        cell.configure(with: FeedImageViewModel.prototypeFeed[indexPath.row])
        return cell
    }
}

extension FeedCell {
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        feedImageView.image = UIImage(named: model.imageName)
    }
}
