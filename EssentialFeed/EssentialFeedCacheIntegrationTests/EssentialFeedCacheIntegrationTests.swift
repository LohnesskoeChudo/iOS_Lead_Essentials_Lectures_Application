//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Василий Клецкин on 20.12.2022.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoImagesOnEmptyCache() throws {
        let sut = makeSut()
        
        let exp = expectation(description: "waiting for loading images")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, [])
            default:
                XCTFail("expected to receive empty feed but got: \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSut() -> LocalFeedLoader {
        let store = CodableFeedStore(storeUrl: storeUrl)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        checkForMemoryLeaks(instance: store)
        checkForMemoryLeaks(instance: sut)
        return sut
    }
    
    private var storeUrl: URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
