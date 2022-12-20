//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 19.12.2022.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertRetrieveDeliversEmptyOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toReceive: .empty, file: file, line: line)
    }
    
    func assertRetrieveHasNoSideEffectsOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toReceiveTwice: .empty, file: file, line: line)
    }
    
    func assertRetrieveDeliversDataOnDataInserted(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = anyFeed().locals
        let timestamp = Date()
        
        insert(sut: sut, feed: feed, timestamp: timestamp)
        
        expect(sut: sut, toReceive: .found(localImages: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertRetrieveHasNoSideEffectsOnDataInserted(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = anyFeed().locals
        let timestamp = Date()
        
        insert(sut: sut, feed: feed, timestamp: timestamp)
        
        expect(sut: sut, toReceiveTwice: .found(localImages: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertInsertDeliversNoErrorOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        XCTAssertNil(error, file: file, line: line)
    }
    
    func assertInsertDeliversNoErrorOnNonEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        let error = insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        XCTAssertNil(error, file: file, line: line)
    }
    
    func assertInsertOverridesPreviousInsertedData(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        let latestFeed = anyFeed().locals
        let latestTimestamp = Date()
        
        insert(sut: sut, feed: latestFeed, timestamp: latestTimestamp)
        
        expect(sut: sut, toReceive: .found(localImages: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }
    
    func assertDeleteFeedDoesNotDeliverErrorOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = delete(sut: sut)
        
        XCTAssertNil(error, file: file, line: line)
    }
    
    func assertDeleteFeedHasNoSideEffectsOnEmptyCache(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(sut: sut)
        
        expect(sut: sut, toReceive: .empty, file: file, line: line)
    }
    
    func assertDeleteFeedRemovesCacheAfterInsertion(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        delete(sut: sut)
        
        expect(sut: sut, toReceive: .empty)
    }
    
    
    func assertOperationsRunSerially(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
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
        
        wait(for: [operation1, operation2, operation3], timeout: 1.0)
        XCTAssertEqual(operations, [operation1, operation2, operation3], file: file, line: line)
    }
    
    // MARK: - Helpers:
    
    @discardableResult
    func insert(sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "Waiting for retrival")
        var error: Error?
        sut.insert(feed: feed, timestamp: timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    func expect(sut: FeedStore, toReceive expectedResult: FeedRetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    func expect(sut: FeedStore, toReceiveTwice expectedResult: FeedRetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toReceive: expectedResult, file: file, line: line)
        expect(sut: sut, toReceive: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func delete(sut: FeedStore) -> Error? {
        var error: Error?
        let exp = expectation(description: "Waiting for retrival")
        sut.deleteFeed { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return error
    }
}
