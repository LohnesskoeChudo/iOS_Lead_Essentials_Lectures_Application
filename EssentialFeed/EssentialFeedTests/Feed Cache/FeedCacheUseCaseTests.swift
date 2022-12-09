//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 09.12.2022.
//

import XCTest

final class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deletionRequestsCount = 0
}

final class FeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotTriggerFeedDeletion() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletionRequestsCount, 0)
    }
}
