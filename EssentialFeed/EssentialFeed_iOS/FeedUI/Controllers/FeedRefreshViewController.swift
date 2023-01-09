//
//  FeedRefreshViewController.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    lazy var view = bind(UIRefreshControl())
    let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init()
        
    }
    
    @objc func refresh() {
        viewModel.load()
    }
    
    private func bind(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChanged = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
