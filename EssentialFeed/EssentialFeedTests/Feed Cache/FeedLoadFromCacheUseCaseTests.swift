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
        
        let exp = expectation(description: "waiting for retrieval error")
        sut.load() { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError as NSError, error)
            default:
                XCTFail("Expected failure, received: \(result)")
            }
            exp.fulfill()
        }
        store.completeRetrievalWith(error: error)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError, error)
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
