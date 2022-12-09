//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 09.12.2022.
//

import XCTest
import EssentialFeed

class FeedStoreSpy: FeedStore {
    enum Message: Equatable {
        case deletion
        case insertion(items: [FeedItem], timestamp: Date)
    }
    
    var deletionCompletions: [FeedStore.DeletionCompletion] = []
    var insertionCompletion: [FeedStore.InsertionCompletion] = []
    var messages: [Message] = []
    
    func deleteItems(completion: @escaping (Error?) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.insertion(items: items, timestamp: timestamp))
        insertionCompletion.append(completion)
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
    
    func completeInsetionWithSuccess(at index: Int = 0) {
        insertionCompletion[index](nil)
    }
}

final class FeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotTriggerFeedDeletion() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_triggersFeedDeletion() {
        let (store, sut) = makeSut()
        
        sut.save(items: anyItems()) { _ in }
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotInsertOnDeletionError() {
        let (store, sut) = makeSut()
        
        sut.save(items: anyItems()) { _ in }
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
        let error = anyNsError()
        
        expect(sut: sut, toReceive: error, when: {
            store.completeDeletionWith(error: error)
        })
    }
    
    func test_save_receivesErrorOnInsertionError() {
        let (store, sut) = makeSut()
        let error = anyNsError()
        
        expect(sut: sut, toReceive: error, when: {
            store.completeDeletionWithSuccess()
            store.completeInsertionWith(error: error)
        })
    }
    
    func test_save_returnNoErrorOnInsertionSuccess() {
        let (store, sut) = makeSut()
        
        expect(sut: sut, toReceive: nil, when: {
            store.completeDeletionWithSuccess()
            store.completeInsetionWithSuccess()
        })
    }
    
    // MARK: - Helpers
    
    private func expect(sut: LocalFeedLoader, toReceive error: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "waiting for save")
        var receivedError: NSError?
        sut.save(items: anyItems()) { error in
            receivedError = error as? NSError
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError, error, file: file, line: line)
    }
    
    private func makeSut(dateProvider: @escaping (() -> Date) = Date.init) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: dateProvider)
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: store)
        return (store, sut)
    }
    
    private func anyItems() -> [FeedItem] {
        [uniqueItem(), uniqueItem(), uniqueItem()]
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
