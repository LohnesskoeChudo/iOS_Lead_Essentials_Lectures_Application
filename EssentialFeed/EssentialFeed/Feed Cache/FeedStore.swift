//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 09.12.2022.
//

import Foundation

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = ((DeletionResult) -> Void)
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = ((InsertionResult) -> Void)
    
    typealias CachedResult = (localImages: [LocalFeedImage], timestamp: Date)
    typealias RetrievalResult = Result<CachedResult?, Error>
    typealias RetrievalCompletion = ((RetrievalResult) -> Void)
    
    func deleteFeed(completion: @escaping DeletionCompletion)
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
