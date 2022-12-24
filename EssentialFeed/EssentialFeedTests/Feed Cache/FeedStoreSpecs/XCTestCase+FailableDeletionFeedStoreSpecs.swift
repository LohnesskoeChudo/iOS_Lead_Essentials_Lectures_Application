//
//  XCTestCase+FailableDeletionFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 20.12.2022.
//

import XCTest
import EssentialFeed

extension FailableDeletionFeedStoreSpecs where Self: XCTestCase {
    func assertDeleteFeedDeliversErrorOnFailure(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = delete(sut: sut)
        
        XCTAssertNotNil(error, file: file, line: line)
    }
    
    func assertDeleteFeedHasNoSideEffectsOnFailure(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(sut: sut)
        
        expect(sut: sut, toReceive: .success(.none), file: file, line: line)
    }
}
