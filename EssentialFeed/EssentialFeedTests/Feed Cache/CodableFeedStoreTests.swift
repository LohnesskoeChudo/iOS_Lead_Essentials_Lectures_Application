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
        
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        expect(sut: sut, toReceive: .empty)
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_retrieveAfterInsertion_returnsDataOnDataSuccessfullyInserted() {
        let sut = makeSut()
        let feed = anyFeed().locals
        let timestamp = Date()
        
        insert(sut: sut, feed: feed, timestamp: timestamp)
        
        expect(sut: sut, toReceive: .found(localImages: feed, timestamp: timestamp))
    }
    
    func test_retrieveTwiceAfterInsertion_hasNoSideEffectsOnDataSuccessfullyInserted() {
        let sut = makeSut()
        let feed = anyFeed().locals
        let timestamp = Date()
        
        insert(sut: sut, feed: feed, timestamp: timestamp)
        
        expect(sut: sut, toReceive: .found(localImages: feed, timestamp: timestamp))
        expect(sut: sut, toReceive: .found(localImages: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversErrorOnFailure() {
        let storeUrl = self.storeUrl
        let sut = makeSut(storeUrl: storeUrl)
        
        try! Data("invalid data".utf8).write(to: storeUrl)
        
        expect(sut: sut, toReceive: .failure(anyNsError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeUrl = self.storeUrl
        let sut = makeSut(storeUrl: storeUrl)
        
        try! Data("invalid data".utf8).write(to: storeUrl)
        
        expect(sut: sut, toReceive: .failure(anyNsError()))
        expect(sut: sut, toReceive: .failure(anyNsError()))
    }
    
    // MARK: - Helpers:
    
    private func makeSut(storeUrl: URL? = nil) -> CodableFeedStore {
        let store = CodableFeedStore(storeUrl: storeUrl ?? self.storeUrl)
        checkForMemoryLeaks(instance: store)
        return store
    }
    
    private func insert(sut: CodableFeedStore, feed: [LocalFeedImage], timestamp: Date, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrival")
        sut.insert(feed: feed, timestamp: timestamp) { insertionError in
            guard insertionError == nil else {
                return XCTFail("Expect to insert successfully", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(sut: CodableFeedStore, toReceive expectedResult: FeedRetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for retrival")
        sut.retrieve() { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.failure, .failure), (.empty, .empty):
                break
            case let (.found(expectedFeed, expectedTimestamp), .found(receivedFeed, receivedTimestamp)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
            default:
                XCTFail("Received: \(receivedResult) but expected: \(expectedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: storeUrl)
    }
    
    private var storeUrl: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
