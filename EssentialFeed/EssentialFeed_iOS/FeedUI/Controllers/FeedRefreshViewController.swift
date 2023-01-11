//
//  FeedRefreshViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    lazy var view = makeView()
    let loadFeed: () -> Void
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
        super.init()
    }
    
    @objc func refresh() {
        loadFeed()
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
