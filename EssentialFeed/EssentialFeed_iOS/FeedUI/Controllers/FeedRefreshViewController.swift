//
//  FeedRefreshViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

protocol FeedLoadingViewDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    lazy var view = makeView()
    let delegate: FeedLoadingViewDelegate
    
    init(delegate: FeedLoadingViewDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(loading: Bool) {
        if loading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func makeView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
