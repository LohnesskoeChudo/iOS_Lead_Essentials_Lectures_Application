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
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        store.deleteItems() { [unowned self] error in
            if error == nil {
                store.insert(items: items, timestamp: currentDate())
            }
        }
    }
}

class FeedStore {
    var deletionRequestsCount = 0
    var insertionRequestCount = 0
    
    var deletionCompletions: [(Error?) -> Void] = []
    var insertedItems: (item: [FeedItem], timestamp: Date)?
    
    func deleteItems(completion: @escaping (Error?) -> Void) {
        deletionRequestsCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeWith(error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(items: [FeedItem], timestamp: Date) {
        insertionRequestCount += 1
        insertedItems = (items, timestamp)
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
    
    func test_save_insertsItemsWithTimestampOnDeletionSuccess() {
        let currentDate = Date()
        let (store, sut) = makeSut(dateProvider: { currentDate })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.insertionRequestCount, 1)
        XCTAssertEqual(store.insertedItems?.item, items)
        XCTAssertEqual(store.insertedItems?.timestamp, currentDate)
    }
    
    // MARK: - Helpers
    
    private func makeSut(dateProvider: @escaping (() -> Date) = Date.init) -> (FeedStore, LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: dateProvider)
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
