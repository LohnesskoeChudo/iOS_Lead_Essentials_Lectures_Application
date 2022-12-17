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
    
    public typealias SaveResult = Error?
    public typealias LoadResult = FeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteFeed() { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.insert(feed: feed, completion: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(localFeed, timestamp) where self.validate(timestamp: timestamp):
                completion(.success(localFeed.models))
            case .found:
                completion(.success([]))
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    public func validate() {
        store.retrieve { [unowned self] result in
            switch result {
            case let .found(_, timestamp) where !validate(timestamp: timestamp):
                self.store.deleteFeed { _ in }
            case .failure:
                self.store.deleteFeed { _ in }
            case .found, .empty:
                break
            }
        }
    }
    
    private func insert(feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed: feed.local, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    private func validate(timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else { return false }
        return currentDate() < maxAge
    }
}

extension Array where Element == FeedImage {
    var local: [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

extension Array where Element == LocalFeedImage {
    var models: [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
