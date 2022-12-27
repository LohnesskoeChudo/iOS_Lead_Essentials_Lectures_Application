//
//  FeedCell.swift
//  Prototype
//
//  Created by Василий Клецкин on 27.12.2022.
//

import UIKit

final class FeedCell: UITableViewCell {
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedImageView.alpha = 0
    }
    
    func fade(in image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.feedImageView.alpha = 1
        }
    }
}
