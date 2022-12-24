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

    func test_load_deliversNoImagesOnEmptyCache() throws {
        let sut = try makeSut()
        
        load(sut: sut, expectedResult: .success([]))
    }
    
    func test_load_deliversFeedSavedOnAnotherInstance() throws {
        let sutForSaving = try makeSut()
        let sutForLoading = try makeSut()
        let feed = anyFeed().models
        
        save(with: sutForSaving, feed: feed)
        
        load(sut: sutForLoading, expectedResult: .success(feed))
    }
    
    func test_save_overridesCachePreviouslyInsertedByAnotherInstanse() throws {
        let firstSavingSut = try makeSut()
        let firstFeed = anyFeed().models
        let latestSavingSut = try makeSut()
        let latestFeed = anyFeed().models
        let loadingSut = try makeSut()
        
        save(with: firstSavingSut, feed: firstFeed)
        save(with: latestSavingSut, feed: latestFeed)
        
        load(sut: loadingSut, expectedResult: .success(latestFeed))
    }
    
    // MARK: - Helpers:
    
    private func makeSut() throws -> LocalFeedLoader {
        let store = try CoreDataFeedStore(storeURL: storeUrl)
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
    
    private func save(with sut: LocalFeedLoader, feed: [FeedImage]) {
        let exp = expectation(description: "waiting for save")
        sut.save(feed: feed) { error in
            XCTAssertNil(error, "expected to successfully save feed")
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
