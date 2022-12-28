//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Василий Клецкин on 28.12.2022.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.SpyLoader) {}
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotTriggerLoading() {
        let loader = SpyLoader()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    final class SpyLoader {
        var loadCallCount = 0
    }
}
