//
//  Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import CoreData

class FeedStoreChallengeTests: XCTestCase, FailableFeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertRetrieveDeliversEmptyOnEmptyCache(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertRetrieveHasNoSideEffectsOnEmptyCache(sut: sut)
    }
    
    func test_retrieve_deliversDataOnDataInserted() throws {
        let sut = try makeSUT()
        
        assertRetrieveDeliversDataOnDataInserted(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnDataInserted() throws {
        let sut = try makeSUT()
        
        assertRetrieveHasNoSideEffectsOnDataInserted(sut: sut)
    }
    
    func test_retrieve_deliversErrorOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()

        let sut = try makeSUT()

        assertRetrieveDeliversErrorOnFailure(sut: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingFetchStub()
        stub.startIntercepting()

        let sut = try makeSUT()

        assertRetrieveHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertInsertDeliversNoErrorOnEmptyCache(sut: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertInsertDeliversNoErrorOnNonEmptyCache(sut: sut)
    }
    
    func test_insert_overridesPreviousInsertedData() throws {
        let sut = try makeSUT()
        
        assertInsertOverridesPreviousInsertedData(sut: sut)
    }
    
    func test_insert_deliversErrorOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()

        let sut = try makeSUT()

        assertInsertDeliversErrorOnFailure(sut: sut)
    }
    
    func test_insert_hasNoSideEffectsOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        stub.startIntercepting()

        let sut = try makeSUT()

        assertInsertHasNoSideEffectsOnFailure(sut: sut)
    }
    
    func test_deleteFeed_doesNotDeliverErrorOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertDeleteFeedDoesNotDeliverErrorOnEmptyCache(sut: sut)
    }
    
    func test_deleteFeed_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()
        
        assertDeleteFeedHasNoSideEffectsOnEmptyCache(sut: sut)
    }
    
    func test_deleteFeed_removesCacheAfterInsertion() throws {
        let sut = try makeSUT()
        
        assertDeleteFeedRemovesCacheAfterInsertion(sut: sut)
    }
    
    func test_deleteFeed_deliversErrorOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = anyFeed().locals
        let timestamp = Date()
        let sut = try makeSUT()

        insert(sut: sut, feed: feed, timestamp: timestamp)

        stub.startIntercepting()

        let deletionError = delete(sut: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_deleteFeed_hasNoSideEffectsOnFailure() throws {
        let stub = NSManagedObjectContext.alwaysFailingSaveStub()
        let feed = anyFeed().locals
        let timestamp = Date()
        let sut = try makeSUT()

        insert(sut: sut, feed: feed, timestamp: timestamp)

        stub.startIntercepting()

        delete(sut: sut)

        expect(sut: sut, toReceive: .found(localImages: feed, timestamp: timestamp))
    }
    
    func test_deleteFeed_removesAllObjects() throws {
        let sut = try makeSUT()

        insert(sut: sut, feed: anyFeed().locals, timestamp: Date())

        delete(sut: sut)

        let context = try NSPersistentContainer.load(
            name: CoreDataFeedStore.modelName,
            model: XCTUnwrap(CoreDataFeedStore.model),
            url: inMemoryStoreURL()
        ).viewContext

        let existingObjects = try context.allExistingObjects()

        XCTAssertEqual(existingObjects, [], "found orphaned objects in Core Data")
    }
    
    func test_operations_runSerially() throws {
        let sut = try makeSUT()
        
        assertOperationsRunSerially(sut: sut)
    }
    
    func test_imageEntity_properties() throws {
        let entity = try XCTUnwrap(
            CoreDataFeedStore.model?.entitiesByName["ManagedFeedImage"]
        )

        entity.verify(attribute: "id", hasType: .UUIDAttributeType, isOptional: false)
        entity.verify(attribute: "imageDescription", hasType: .stringAttributeType, isOptional: true)
        entity.verify(attribute: "location", hasType: .stringAttributeType, isOptional: true)
        entity.verify(attribute: "url", hasType: .URIAttributeType, isOptional: false)
    }

	// - MARK: Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> FeedStore {
		let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL())
        checkForMemoryLeaks(instance: sut, file: file, line: line)
		return sut
	}

	private func inMemoryStoreURL() -> URL {
		URL(fileURLWithPath: "/dev/null")
			.appendingPathComponent("\(type(of: self)).store")
	}
}

extension CoreDataFeedStore.ModelNotFound: CustomStringConvertible {
	public var description: String {
		"Core Data Model '\(modelName).xcdatamodeld' not found. You need to create it in the production target."
	}
}
