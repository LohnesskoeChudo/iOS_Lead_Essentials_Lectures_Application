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
    
    func deleteFeed(completion: @escaping (Error?) -> Void)
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void)
}
