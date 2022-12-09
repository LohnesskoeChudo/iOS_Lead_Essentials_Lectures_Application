//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 09.12.2022.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias Result = (Error?) -> Void
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping Result) {
        store.deleteItems() { [unowned self] error in
            if error == nil {
                store.insert(items: items, timestamp: currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}
