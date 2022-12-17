//
//  FeedCacheValidationUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 17.12.2022.
//

import XCTest
import EssentialFeed

final class FeedCacheValidationUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_validate_removesCacheEffectsOnRetrievalError() {
        let (store, sut) = makeSut()
        
        sut.validate()
        store.completeRetrievalWith(error: anyNsError())
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    // MARK: - Helpers:
    
    private func makeSut(dateProvider: @escaping (() -> Date) = Date.init) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: dateProvider)
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: store)
        return (store, sut)
    }
}
