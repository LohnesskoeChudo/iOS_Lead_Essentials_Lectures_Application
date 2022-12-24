//
// Copyright © Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedCache)
final class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let entityName = ManagedCache.entity().name!
		let request = NSFetchRequest<ManagedCache>(entityName: entityName)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
		try ManagedCache.find(in: context).map(context.delete)
		return ManagedCache(context: context)
	}
}

extension ManagedCache {
	var localFeed: [LocalFeedImage] {
		feed.compactMap { ($0 as? ManagedFeedImage)?.localImage }
	}

	static func managedFeed(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: localFeed.map { local in
			let managed = ManagedFeedImage(context: context)
			managed.id = local.id
			managed.imageDescription = local.description
			managed.location = local.location
			managed.url = local.url
			return managed
		})
	}
}
