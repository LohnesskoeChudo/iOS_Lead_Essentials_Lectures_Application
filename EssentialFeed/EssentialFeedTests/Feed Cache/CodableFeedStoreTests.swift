//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 18.12.2022.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    override func setUp() {
        super.setUp()
        removeArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        removeArtifacts()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSut()
        
        assertRetrieveDeliversEmptyOnEmptyCache(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        assertRetrieveHasNoSideEffectsOnEmptyCache(sut: sut)
    }
    
    func test_retrieve_deliversDataOnDataInserted() {
        let sut = makeSut()
        
        assertRetrieveDeliversDataOnDataInserted(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnDataInserted() {
        let sut = makeSut()
        
        assertRetrieveHasNoSideEffectsOnDataInserted(sut: sut)
    }
    
    func test_retrieve_deliversErrorOnFailure() {
        let storeUrl = self.storeUrl
        let sut = makeSut(storeUrl: storeUrl)
        
        try! Data("invalid data".utf8).write(to: storeUrl)
        
        assertRetrieveDeliversErrorOnFailure(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeUrl = self.storeUrl
        let sut = makeSut(storeUrl: storeUrl)
        
        try! Data("invalid data".utf8).write(to: storeUrl)
        
        assertRetrieveHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSut()
        
        assertInsertDeliversNoErrorOnEmptyCache(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSut()
        
        assertInsertDeliversNoErrorOnNonEmptyCache(sut: sut)
    }
    
    func test_insert_overridesPreviousInsertedData() {
        let sut = makeSut()
        
        assertInsertOverridesPreviousInsertedData(sut: sut)
    }
    
    func test_insert_deliversErrorOnFailure() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSut(storeUrl: invalidStoreUrl)
        
        assertInsertDeliversErrorOnFailure(sut: sut)
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSut(storeUrl: invalidStoreUrl)
        
        assertInsertHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_deleteFeed_doesNotDeliverErrorOnEmptyCache() {
        let sut = makeSut()
        
        assertDeleteFeedDoesNotDeliverErrorOnEmptyCache(sut: sut)
    }
    
    func test_deleteFeed_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        assertDeleteFeedHasNoSideEffectsOnEmptyCache(sut: sut)
    }
    
    func test_deleteFeed_removesCacheAfterInsertion() {
        let sut = makeSut()
        
        assertDeleteFeedRemovesCacheAfterInsertion(sut: sut)
    }
    
    func test_deleteFeed_deliversErrorOnFailure() {
        let notPermittedUrl = cachesDirectory()
        let sut = makeSut(storeUrl: notPermittedUrl)
        
        assertDeleteFeedDeliversErrorOnFailure(sut: sut)
    }
    
    func test_deleteFeed_hasNoSideEffectsOnFailure() {
        let notPermittedUrl = cachesDirectory()
        let sut = makeSut(storeUrl: notPermittedUrl)
        
        assertDeleteFeedHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_operations_runSerially() {
        let sut = makeSut()
        
        assertOperationsRunSerially(sut: sut)
    }
    
    // MARK: - Helpers:
    
    private func makeSut(storeUrl: URL? = nil) -> FeedStore {
        let store = CodableFeedStore(storeUrl: storeUrl ?? self.storeUrl)
        checkForMemoryLeaks(instance: store)
        return store
    }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: storeUrl)
        try? FileManager.default.removeItem(at: cachesDirectory())
    }
    
    private var storeUrl: URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
