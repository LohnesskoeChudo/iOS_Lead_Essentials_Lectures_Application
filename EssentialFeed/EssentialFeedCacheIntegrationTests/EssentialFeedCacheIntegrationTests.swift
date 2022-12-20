//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Василий Клецкин on 20.12.2022.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        removeArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        removeArtifacts()
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let sut = makeSut()
        
        load(sut: sut, expectedResult: .success([]))
    }
    
    func test_load_deliversFeedSavedOnAnotherInstance() {
        let sutForSaving = makeSut()
        let sutForLoading = makeSut()
        let feed = anyFeed().models
        
        let exp1 = expectation(description: "waiting for save")
        sutForSaving.save(feed: feed) { error in
            XCTAssertNil(error, "expected to successfully save feed")
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 1.0)
        
        load(sut: sutForLoading, expectedResult: .success(feed))
    }
    
    func test_save_overridesCachePreviouslyInsertedByAnotherInstanse() {
        let firstSavingSut = makeSut()
        let firstFeed = anyFeed().models
        let latestSavingSut = makeSut()
        let latestFeed = anyFeed().models
        let loadingSut = makeSut()
        
        
        let exp1 = expectation(description: "waiting for save")
        firstSavingSut.save(feed: firstFeed) { error in
            XCTAssertNil(error, "expected to successfully save feed")
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 1.0)
        
        let exp2 = expectation(description: "waiting for save")
        latestSavingSut.save(feed: latestFeed) { error in
            XCTAssertNil(error, "expected to successfully save feed")
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 1.0)
        
        load(sut: loadingSut, expectedResult: .success(latestFeed))
    }
    
    // MARK: - Helpers:
    
    private func makeSut() -> LocalFeedLoader {
        let store = CodableFeedStore(storeUrl: storeUrl)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        checkForMemoryLeaks(instance: store)
        checkForMemoryLeaks(instance: sut)
        return sut
    }
    
    private func load(sut: LocalFeedLoader, expectedResult: LocalFeedLoader.LoadResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "waiting for load")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(loadedFeed), .success(expectedFeed)):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
            default:
                XCTFail("expected to receive: \(expectedResult) but got: \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: storeUrl)
    }
    
    private var storeUrl: URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
