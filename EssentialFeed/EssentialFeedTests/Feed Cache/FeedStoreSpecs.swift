//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 19.12.2022.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversDataOnDataInserted()
    func test_retrieve_hasNoSideEffectsOnDataInserted()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviousInsertedData()
    
    func test_deleteFeed_doesNotDeliverErrorOnEmptyCache()
    func test_deleteFeed_hasNoSideEffectsOnEmptyCache()
    func test_deleteFeed_removesCacheAfterInsertion()

    func test_operations_runSerially()
}

protocol FailableRetrievalFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnFailure()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertionFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnFailure()
    func test_insert_hasNoSideEffectsOnFailure()
}

protocol FailableDeletionFeedStoreSpecs: FeedStoreSpecs {
    func test_deleteFeed_deliversErrorOnFailure()
    func test_deleteFeed_hasNoSideEffectsOnFailure()
}

typealias FailableFeedStoreSpecs = FailableDeletionFeedStoreSpecs & FailableInsertionFeedStoreSpecs & FailableRetrievalFeedStoreSpecs
