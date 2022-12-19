//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 18.12.2022.
//

import Foundation

private extension Array where Element == LocalFeedImage {
    var codables: [CodableFeedStore.CodableFeedImage] {
        map { .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

public final class CodableFeedStore {
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
    
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        if let data = try? Data(contentsOf: storeUrl) {
            do {
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                completion(.found(localImages: cache.locals, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.empty)
        }
    }
    
    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(feed: feed.codables, timestamp: timestamp)
        let encodedData = try! JSONEncoder().encode(cache)
        try! encodedData.write(to: storeUrl)
        completion(nil)
    }
}
