//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 09.12.2022.
//

import XCTest
import EssentialFeed

final class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteItems()
    }
}

class FeedStore {
    var deletionRequestsCount = 0
    
    func deleteItems() {
        deletionRequestsCount += 1
    }
}

final class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotTriggerFeedDeletion() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletionRequestsCount, 0)
    }
    
    func test_save_triggersFeedDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        
        XCTAssertEqual(store.deletionRequestsCount, 1)
    }
    
    // MARK: - Helpers
    
    private func uniqueItem() -> FeedItem {
        FeedItem(
            id: UUID(),
            description: "any description",
            location: "any location",
            imageUrl: anyUrl()
        )
    }
}
