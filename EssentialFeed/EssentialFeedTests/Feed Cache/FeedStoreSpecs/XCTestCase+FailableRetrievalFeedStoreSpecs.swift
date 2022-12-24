//
//  XCTestCase+FailableRetrievalFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 20.12.2022.
//

import XCTest
import EssentialFeed

extension FailableRetrievalFeedStoreSpecs where Self: XCTestCase {
    func assertRetrieveDeliversErrorOnFailure(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toReceive: .failure(anyNsError()), file: file, line: line)
    }
    
    func assertRetrieveHasNoSideEffectsOnFailure(sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toReceiveTwice: .failure(anyNsError()), file: file, line: line)
    }
}
