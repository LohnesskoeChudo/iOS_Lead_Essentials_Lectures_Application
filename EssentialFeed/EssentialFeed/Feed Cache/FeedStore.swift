//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 09.12.2022.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    typealias RetrievalCompletion = ((Error?) -> Void)
    
    func deleteFeed(completion: @escaping DeletionCompletion)
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
