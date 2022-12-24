//
//  Copyright © Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	public static let modelName = "FeedStore"
	public static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	public struct ModelNotFound: Error {
		public let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	deinit {
		cleanUpReferencesToPersistentStores()
	}

	private func cleanUpReferencesToPersistentStores() {
		context.performAndWait {
			let coordinator = self.container.persistentStoreCoordinator
			try? coordinator.persistentStores.forEach(coordinator.remove)
		}
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform { [context] in
            completion(Result(catching: {
                try ManagedCache.find(in: context).map {
                    CachedResult(localImages: $0.localFeed, timestamp: $0.timestamp)
                }
            }))
		}
	}

    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [context] in
			do {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.feed = ManagedCache.managedFeed(from: feed, in: context)
				managedCache.timestamp = timestamp
				try context.save()
                completion(.success(()))
			} catch {
				context.reset()
                completion(.failure(error))
			}
		}
	}
    
    public func deleteFeed(completion: @escaping DeletionCompletion) {
        context.perform { [context] in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(.success(()))
            } catch {
                context.reset()
                completion(.failure(error))
            }
        }
    }
}
