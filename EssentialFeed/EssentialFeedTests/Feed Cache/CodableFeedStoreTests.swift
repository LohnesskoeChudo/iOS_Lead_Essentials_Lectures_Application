//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 18.12.2022.
//

import XCTest
import EssentialFeed

private extension Array where Element == LocalFeedImage {
    var codables: [CodableFeedStore.CodableFeedImage] {
        map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

final class CodableFeedStore {
    struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var locals: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private lazy var storeUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("CodableFeedStore.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        if let data = try? Data(contentsOf: storeUrl) {
            let cache = try! JSONDecoder().decode(Cache.self, from: data)
            completion(.found(localImages: cache.locals, timestamp: cache.timestamp))
        } else {
            completion(.empty)
        }
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(feed: feed.codables, timestamp: timestamp)
        let encodedData = try! JSONEncoder().encode(cache)
        try! encodedData.write(to: storeUrl)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("CodableFeedStore.store")
        try? FileManager.default.removeItem(at: url)
    }
    
    func test_retrieve_resultsWithEmptyOnEmptyCache() {
        let sut = makeSut()
        
        let exp = expectation(description: "Waiting for retrival")
        sut.retrieve() { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result but got: \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        let exp = expectation(description: "Waiting for retrival")
        sut.retrieve() { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result but got: \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertion_returnsDataOnDataSuccessfullyInserted() {
        let sut = makeSut()
        let feed = anyFeed().locals
        let timestamp = Date()
        
        let exp = expectation(description: "Waiting for retrival")
        sut.insert(feed: feed, timestamp: timestamp) { insertionResult in
            guard insertionResult == nil else {
                return XCTFail("Expected 'insert' to success")
            }
            sut.retrieve { retrivalResult in
                switch retrivalResult {
                case let .found(receivedFeed, receivedTimestamp):
                    XCTAssertEqual(feed, receivedFeed)
                    XCTAssertEqual(timestamp, receivedTimestamp)
                default:
                    XCTFail("Expected data but got: \(retrivalResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers:
    
    func makeSut() -> CodableFeedStore {
        let store = CodableFeedStore()
        return store
    }
}

