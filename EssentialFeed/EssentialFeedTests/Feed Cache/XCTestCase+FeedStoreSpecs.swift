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
    
    @discardableResult
    func delete(sut: FeedStore) -> Error? {
        var error: Error?
        let exp = expectation(description: "Waiting for retrival")
        sut.deleteFeed { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return error
    }
}
