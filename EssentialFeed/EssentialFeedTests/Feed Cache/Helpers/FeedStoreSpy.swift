//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 15.12.2022.
//

import EssentialFeed
import Foundation

final class FeedStoreSpy: FeedStore {
    enum Message: Equatable {
        case deletion
        case insertion(feed: [LocalFeedImage], timestamp: Date)
        case retrieve
    }
    
    var deletionCompletions: [FeedStore.DeletionCompletion] = []
    var insertionCompletions: [FeedStore.InsertionCompletion] = []
    var retrivalCompletions: [FeedStore.RetrievalCompletion] = []
    var messages: [Message] = []
    
    func deleteFeed(completion: @escaping FeedStore.DeletionCompletion) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        messages.append(.insertion(feed: feed, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion ){
        messages.append(.retrieve)
        retrivalCompletions.append(completion)
    }
    
    func completeDeletionWith(error: NSError, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeInsertionWith(error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeRetrievalWith(error: NSError, at index: Int = 0) {
        retrivalCompletions[index](.failure(error))
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func completeInsetionWithSuccess(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrivalCompletions[index](.success(.none))
    }
    
    func completeRetrievalWith(localFeed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrivalCompletions[index](.success((localFeed, timestamp)))
    }
}
