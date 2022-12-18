//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 18.12.2022.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        removeArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        removeArtifacts()
    }
    
    func test_retrieve_resultsWithEmptyOnEmptyCache() {
        let sut = makeSut()
        
        let exp = expectation(description: "Waiting for retrival")
        sut.retrieve() { result in
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
        let sut = makeSut()
        
        let exp = expectation(description: "Waiting for retrival")
        sut.retrieve() { firstResult in
            sut.retrieve { secondResult in
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
    
    func test_retrieveAfterInsertion_returnsDataOnDataSuccessfullyInserted() {
        let sut = makeSut()
        let feed = anyFeed().locals
        let timestamp = Date()
        
        let exp = expectation(description: "Waiting for retrival")
        sut.insert(feed: feed, timestamp: timestamp) { insertionResult in
            sut.retrieve { retrivalResult in
                switch retrivalResult {
                case let .found(receivedFeed, receivedTimestamp):
                    XCTAssertEqual(feed, receivedFeed)
                    XCTAssertEqual(timestamp, receivedTimestamp)
                default:
                    XCTFail("Expected data but got: \(retrivalResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers:
    
    private func makeSut() -> CodableFeedStore {
        let store = CodableFeedStore(storeUrl: storeUrl)
        checkForMemoryLeaks(instance: store)
        return store
    }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: storeUrl)
    }
    
    private var storeUrl: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
