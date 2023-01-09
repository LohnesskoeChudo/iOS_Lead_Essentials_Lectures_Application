//
//  FeedImageCell.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 07.01.2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var retryButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func tap() {
        onRetry?()
    }
}
