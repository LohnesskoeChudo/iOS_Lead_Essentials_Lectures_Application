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
