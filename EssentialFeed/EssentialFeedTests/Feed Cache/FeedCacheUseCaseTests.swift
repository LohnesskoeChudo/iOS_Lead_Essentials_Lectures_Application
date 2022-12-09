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
    
    typealias Result = (Error?) -> Void
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem], completion: @escaping Result) {
        store.deleteItems() { [unowned self] error in
            if error == nil {
                store.insert(items: items, timestamp: currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    
    enum Message: Equatable {
        case deletion
        case insertion(items: [FeedItem], timestamp: Date)
    }
    
    var deletionCompletions: [(Error?) -> Void] = []
    var insertionCompletion: [(Error?) -> Void] = []
    var messages: [Message] = []
    
    func deleteItems(completion: @escaping (Error?) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertionWith(error: NSError, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.insertion(items: items, timestamp: timestamp))
        insertionCompletion.append(completion)
    }
}

final class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotTriggerFeedDeletion() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_triggersFeedDeletion() {
        let (store, sut) = makeSut()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotInsertOnDeletionError() {
        let (store, sut) = makeSut()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items) { _ in }
        store.completeDeletionWith(error: anyNsError())
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_insertsItemsWithTimestampOnDeletionSuccess() {
        let currentDate = Date()
        let (store, sut) = makeSut(dateProvider: { currentDate })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items) { _ in }
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.messages, [.deletion, .insertion(items: items, timestamp: currentDate)])
    }
    
    func test_save_receivesErrorOnDeletionError() {
        let (store, sut) = makeSut()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNsError()
        
        let exp = expectation(description: "waiting for save failure")
        var receivedError: NSError?
        sut.save(items: items) { error in
            receivedError = error as? NSError
            exp.fulfill()
        }
        store.completeDeletionWith(error: error)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, error)
    }
    
    func test_save_receivesErrorOnInsertionError() {
        let (store, sut) = makeSut()
        let items = [uniqueItem(), uniqueItem()]
        let error = anyNsError()
        
        let exp = expectation(description: "waiting for save failure")
        var receivedError: NSError?
        sut.save(items: items) { error in
            receivedError = error as? NSError
            exp.fulfill()
        }
        store.completeDeletionWithSuccess()
        store.completeInsertionWith(error: error)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, error)
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
