//
//  FeedViewController.swift
//  Prototype
//
//  Created by Василий Клецкин on 27.12.2022.
//

import UIKit

final class FeedViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)
    }
}
