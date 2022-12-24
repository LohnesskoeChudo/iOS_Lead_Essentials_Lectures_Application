//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 19.12.2022.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws
    func test_retrieve_deliversDataOnDataInserted() throws
    func test_retrieve_hasNoSideEffectsOnDataInserted() throws

    func test_insert_deliversNoErrorOnEmptyCache() throws
    func test_insert_deliversNoErrorOnNonEmptyCache() throws
    func test_insert_overridesPreviousInsertedData() throws
    
    func test_deleteFeed_doesNotDeliverErrorOnEmptyCache() throws
    func test_deleteFeed_hasNoSideEffectsOnEmptyCache() throws
    func test_deleteFeed_removesCacheAfterInsertion() throws

    func test_operations_runSerially() throws
}

protocol FailableRetrievalFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnFailure() throws
    func test_retrieve_hasNoSideEffectsOnFailure() throws
}

protocol FailableInsertionFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnFailure() throws
    func test_insert_hasNoSideEffectsOnFailure() throws
}

protocol FailableDeletionFeedStoreSpecs: FeedStoreSpecs {
    func test_deleteFeed_deliversErrorOnFailure() throws
    func test_deleteFeed_hasNoSideEffectsOnFailure() throws
}

typealias FailableFeedStoreSpecs = FailableDeletionFeedStoreSpecs & FailableInsertionFeedStoreSpecs & FailableRetrievalFeedStoreSpecs
