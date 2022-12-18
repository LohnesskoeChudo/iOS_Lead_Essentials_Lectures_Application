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
    
    func test_validate_doesNotRemoveCacheOnNotExpiredCache() {
        let currentDate = Date()
        let notExpiredDate = currentDate.minusCacheExpirationDate().adding(seconds: 1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.validate()
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: notExpiredDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validate_deletesCacheOnCacheExpirationDate() {
        let currentDate = Date()
        let expirationDate = currentDate.minusCacheExpirationDate()
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.validate()
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    func test_validate_deletesCacheOnExpiredCache() {
        let currentDate = Date()
        let expiredCacheDate = currentDate.minusCacheExpirationDate().adding(seconds: -1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.validate()
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: expiredCacheDate)
        
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

extension Date {
    func minusCacheExpirationDate() -> Date {
        adding(days: -cacheExpirationAgeInDays)
    }
    
    private var cacheExpirationAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: days, to: self) ?? Date()
    }
}
    
extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
