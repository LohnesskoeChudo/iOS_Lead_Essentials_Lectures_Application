//
//  XCTestCase+FailableInsertionFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 20.12.2022.
//

import XCTest
import EssentialFeed

extension FailableInsertionFeedStoreSpecs where Self: XCTestCase {
    func assertInsertDeliversErrorOnFailure(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        XCTAssertNotNil(error, file: file, line: line)
    }
    
    func assertInsertHasNoSideEffectsOnFailure(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())
        
        expect(sut: sut, toReceive: .success(.none), file: file, line: line)
    }
}
