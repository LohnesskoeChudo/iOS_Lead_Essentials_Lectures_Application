//
//  FeedLoadFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 15.12.2022.
//

import XCTest
import EssentialFeed
import Foundation

final class FeedLoadFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotHaveSideEffects() {
        let (store, _) = makeSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_requestsStoreToRetrieve() {
        let (store, sut) = makeSut()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_receivesErrorOnRetrievalError() {
        let (store, sut) = makeSut()
        let error = anyNsError()
        
        expect(sut: sut, result: .failure(error), on: {
            store.completeRetrievalWith(error: error)
        })
    }
    
    func test_load_receivesEmptyFeedOnEmptyCache() {
        let (store, sut) = makeSut()
        
        expect(sut: sut, result: .success([]), on: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_receivesFeedOnNotExpiredCache() {
        let feed = anyFeed()
        let currentDate = Date()
        let notExpiredCacheDate = currentDate.minusCacheExpirationDate().adding(seconds: 1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        expect(sut: sut, result: .success(feed.models), on: {
            store.completeRetrievalWith(localFeed: feed.locals, timestamp: notExpiredCacheDate)
        })
    }
    
    func test_load_receivesEmptyFeedOnExpirationCacheDate() {
        let currentDate = Date()
        let expirationCacheDate = currentDate.minusCacheExpirationDate()
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        expect(sut: sut, result: .success([]), on: {
            store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: expirationCacheDate)
        })
    }
    
    func test_load_receivesEmptyFeedOnExpiredCache() {
        let currentDate = Date()
        let expiredCacheDate = currentDate.minusCacheExpirationDate().adding(seconds: -1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        expect(sut: sut, result: .success([]), on: {
            store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: expiredCacheDate)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (store, sut) = makeSut()
        
        sut.load { _ in }
        store.completeRetrievalWith(error: anyNsError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (store, sut) = makeSut()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNotExpiredCache() {
        let currentDate = Date()
        let notExpiredCacheDate = currentDate.minusCacheExpirationDate().adding(seconds: 1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.load { _ in }
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: notExpiredCacheDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpirationDate() {
        let currentDate = Date()
        let cacheExpirationDate = currentDate.minusCacheExpirationDate()
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.load { _ in }
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: cacheExpirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let currentDate = Date()
        let expiredCacheDate = currentDate.minusCacheExpirationDate().adding(seconds: -1)
        let (store, sut) = makeSut(dateProvider: { currentDate })
        
        sut.load { _ in }
        store.completeRetrievalWith(localFeed: anyFeed().locals, timestamp: expiredCacheDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_doesNotCallbackWhenSutDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = .init(store: store, currentDate: Date.init)
        
        var result: LocalFeedLoader.LoadResult?
        sut?.load { receivedResult in result = receivedResult }
        sut = nil
        store.completeRetrievalWith(error: anyNsError())
        
        XCTAssertNil(result)
    }
    
    // MARK: - Helpers
    private func makeSut(dateProvider: @escaping (() -> Date) = Date.init) -> (FeedStoreSpy, LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: dateProvider)
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: store)
        return (store, sut)
    }
    
    private func expect(sut: LocalFeedLoader, result expectedResult: LocalFeedLoader.LoadResult, on action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "waiting for load")
        sut.load() { result in
            switch (result, expectedResult) {
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), received: \(result)")
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
