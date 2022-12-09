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
    var insertionRequestCount = 0
    
    func deleteItems() {
        deletionRequestsCount += 1
    }
    
    func completeWith(error: NSError) {
        
    }
}

final class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotTriggerFeedDeletion() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.deletionRequestsCount, 0)
    }
    
    func test_save_triggersFeedDeletion() {
        let (store, sut) = makeSut()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        
        XCTAssertEqual(store.deletionRequestsCount, 1)
    }
    
    func test_save_doesNotInsertOnDeletionError() {
        let (store, sut) = makeSut()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeWith(error: anyNsError())
        
        XCTAssertEqual(store.insertionRequestCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSut() -> (FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (store, sut)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(
            id: UUID(),
            description: "any description",
            location: "any location",
            imageUrl: anyUrl()
        )
    }
}
