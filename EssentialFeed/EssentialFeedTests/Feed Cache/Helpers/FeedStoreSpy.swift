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
    var insertionCompletion: [FeedStore.InsertionCompletion] = []
    var retrivalCompletion: [FeedStore.RetrievalCompletion] = []
    var messages: [Message] = []
    
    func deleteFeed(completion: @escaping (Error?) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.insertion(feed: feed, timestamp: timestamp))
        insertionCompletion.append(completion)
    }
    
    func retrieve(completion: @escaping (Error?) -> Void) {
        messages.append(.retrieve)
        retrivalCompletion.append(completion)
    }
    
    func completeDeletionWith(error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertionWith(error: NSError, at index: Int = 0) {
        insertionCompletion[index](error)
    }
    
    func completeRetrievalWith(error: NSError, at index: Int = 0) {
        retrivalCompletion[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsetionWithSuccess(at index: Int = 0) {
        insertionCompletion[index](nil)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrivalCompletion[index](nil)
    }
}
