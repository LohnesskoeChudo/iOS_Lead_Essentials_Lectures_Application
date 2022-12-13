//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 09.12.2022.
//

import XCTest
import EssentialFeed

final class FeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotTriggerFeedDeletion() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_triggersFeedDeletion() {
        let (store, sut) = makeSut()
        
        sut.save(feed: anyFeed().models) { _ in }
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotInsertOnDeletionError() {
        let (store, sut) = makeSut()
        
        sut.save(feed: anyFeed().models) { _ in }
        store.completeDeletionWith(error: anyNsError())
        
        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_insertsFeedWithTimestampOnDeletionSuccess() {
        let currentDate = Date()
        let (store, sut) = makeSut(dateProvider: { currentDate })
        let feed = anyFeed()
        
        sut.save(feed: feed.models) { _ in }
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.messages, [.deletion, .insertion(feed: feed.locals, timestamp: currentDate)])
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
    
    func test_save_doesNotCallCompletionOnDeletionErrorWithSutDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult: LocalFeedLoader.Result?
        sut?.save(feed: anyFeed().models) { result in
            receivedResult = result
        }
        sut = nil
        store.completeDeletionWith(error: anyNsError())
        
        XCTAssert(receivedResult == nil)
    }
    
    func test_save_doesNotCallCompletionOnInsertionErrorWhenSutHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult: LocalFeedLoader.Result?
        sut?.save(feed: anyFeed().models) { result in
            receivedResult = result
        }
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertionWith(error: anyNsError())
        
        XCTAssert(receivedResult == nil)
    }
    
    // MARK: - Helpers
    
    private func expect(sut: LocalFeedLoader, toReceive error: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "waiting for save")
        var receivedError: NSError?
        sut.save(feed: anyFeed().models) { error in
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
    
    private func anyFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage(), uniqueImage()]
        let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (models, locals)
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(
            id: UUID(),
            description: "any description",
            location: "any location",
            url: anyUrl()
        )
    }
    
    final class FeedStoreSpy: FeedStore {
        enum Message: Equatable {
            case deletion
            case insertion(feed: [LocalFeedImage], timestamp: Date)
        }
        
        var deletionCompletions: [FeedStore.DeletionCompletion] = []
        var insertionCompletion: [FeedStore.InsertionCompletion] = []
        var messages: [Message] = []
        
        func deleteFeed(completion: @escaping (Error?) -> Void) {
            messages.append(.deletion)
            deletionCompletions.append(completion)
        }
        
        func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
            messages.append(.insertion(feed: feed, timestamp: timestamp))
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
}
