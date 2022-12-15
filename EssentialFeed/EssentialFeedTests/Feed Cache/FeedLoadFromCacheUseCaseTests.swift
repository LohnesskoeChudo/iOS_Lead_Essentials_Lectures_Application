//
//  FeedLoadFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 15.12.2022.
//

import XCTest
import EssentialFeed

final class FeedLoadFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    // MARK: - Helpers
    private func makeSut(dateProvider: @escaping (() -> Date) = Date.init) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: dateProvider)
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: store)
        return (store, sut)
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
