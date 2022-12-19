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
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSut()
        
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        expect(sut: sut, toReceive: .empty)
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_retrieve_deliversDataOnDataInserted() {
        let sut = makeSut()
        let feed = anyFeed().locals
        let timestamp = Date()
        
        insert(sut: sut, feed: feed, timestamp: timestamp)
        
        expect(sut: sut, toReceive: .found(localImages: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnDataInserted() {
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSut()
        
        let error = insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        XCTAssertNil(error)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSut()
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        let error = insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        XCTAssertNil(error)
    }
    
    func test_insert_overridesPreviousInsertedData() {
        let sut = makeSut()
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        let latestFeed = anyFeed().locals
        let latestTimestamp = Date()
        
        insert(sut: sut, feed: latestFeed, timestamp: latestTimestamp)
        
        expect(sut: sut, toReceive: .found(localImages: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnFailure() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSut(storeUrl: invalidStoreUrl)
        
        let error = insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        XCTAssertNotNil(error)
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSut(storeUrl: invalidStoreUrl)
        
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_deleteFeed_doesNotDeliverErrorOnEmptyCache() {
        let sut = makeSut()
        
        let error = delete(sut: sut)
        
        XCTAssertNil(error)
    }
    
    func test_deleteFeed_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        delete(sut: sut)
        
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_deleteFeed_removesCacheAfterInsertion() {
        let sut = makeSut()
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        delete(sut: sut)
        
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_deleteFeed_deliversErrorOnFailure() {
        let notPermittedUrl = cachesDirectory()
        let sut = makeSut(storeUrl: notPermittedUrl)
        
        let error = delete(sut: sut)
        
        XCTAssertNotNil(error)
    }
    
    func test_deleteFeed_hasNoSideEffectsOnFailure() {
        let notPermittedUrl = cachesDirectory()
        let sut = makeSut(storeUrl: notPermittedUrl)
        
        delete(sut: sut)
        
        expect(sut: sut, toReceive: .empty)
    }
    
    func test_operations_runSerially() {
        let sut = makeSut()
        
        var operations: [XCTestExpectation] = []
        let operation1 = expectation(description: "operation1")
        sut.insert(feed: anyFeed().locals, timestamp: Date()) { _ in
            operations.append(operation1)
            operation1.fulfill()
        }
        
        let operation2 = expectation(description: "operation2")
        sut.deleteFeed { _ in
            operations.append(operation2)
            operation2.fulfill()
        }
        
        let operation3 = expectation(description: "operation3")
        sut.insert(feed: anyFeed().locals, timestamp: Date()) { _ in
            operations.append(operation3)
            operation3.fulfill()
        }
        
        wait(for: [operation1, operation2, operation3], timeout: 5.0)
        XCTAssertEqual(operations, [operation1, operation2, operation3])
    }
    
    // MARK: - Helpers:
    
    private func makeSut(storeUrl: URL? = nil) -> FeedStore {
        let store = CodableFeedStore(storeUrl: storeUrl ?? self.storeUrl)
        checkForMemoryLeaks(instance: store)
        return store
    }
    
    @discardableResult
    private func insert(sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "Waiting for retrival")
        var error: Error?
        sut.insert(feed: feed, timestamp: timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    private func expect(sut: FeedStore, toReceive expectedResult: FeedRetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    @discardableResult
    private func delete(sut: FeedStore) -> Error? {
        var error: Error?
        let exp = expectation(description: "Waiting for retrival")
        sut.deleteFeed { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return error
    }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: storeUrl)
    }
    
    private var storeUrl: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
