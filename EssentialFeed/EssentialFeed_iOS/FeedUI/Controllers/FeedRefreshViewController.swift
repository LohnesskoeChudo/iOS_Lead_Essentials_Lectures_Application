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
    let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
        super.init()
        
    }
    
    @objc func refresh() {
        presenter.load()
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
