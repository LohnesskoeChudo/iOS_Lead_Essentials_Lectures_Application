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
    
    func test_validate_doesNotRemoveCacheOnEmptyCache() {
        let (store, sut) = makeSut()
        
        sut.validate()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validate_doesNotRemoveCacheOnLessThan7DaysOldCache() {
        let currentDate = Date()
        let lessThan7DaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: 1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.validate()
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: lessThan7DaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validate_deletesCacheOn7DaysOldCache() {
        let currentDate = Date()
        let a7DaysOldTimestamp = currentDate.adding(days: -7)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.validate()
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: a7DaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    func test_validate_deletesCacheOnMoreThan7DaysOldCache() {
        let currentDate = Date()
        let moreThan7DaysOldTimestamp = currentDate.adding(days: -7).adding(seconds: -1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.validate()
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: moreThan7DaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    func test_validate_doesNotDeleteCacheOnSutDeallocation() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = .init(store: store, currentDate: Date.init)
        
        sut?.validate()
        sut = nil
        store.completeRetrievalWith(error: anyNsError())
        
        XCTAssertEqual(store.messages, [.retrieve])
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
