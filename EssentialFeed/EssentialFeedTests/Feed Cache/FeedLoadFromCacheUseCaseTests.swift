//
//  FeedLoadFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 15.12.2022.
//

import XCTest
import EssentialFeed

final class FeedLoadFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    // MARK: - Helpers
    private func makeSut(dateProvider: @escaping (() -> Date) = Date.init) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: dateProvider)
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: store)
        return (store, sut)
    }
}
