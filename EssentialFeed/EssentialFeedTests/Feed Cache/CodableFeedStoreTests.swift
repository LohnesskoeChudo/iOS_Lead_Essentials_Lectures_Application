//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 18.12.2022.
//

import XCTest
import EssentialFeed

final class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_resultsWithEmptyOnEmptyCache() {
        let store = CodableFeedStore()
        
        let exp = expectation(description: "Waiting for retrival")
        store.retrieve() { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result but got: \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnEmptyCache() {
        let store = CodableFeedStore()
        
        let exp = expectation(description: "Waiting for retrival")
        store.retrieve() { firstResult in
            store.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result but got: \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}

