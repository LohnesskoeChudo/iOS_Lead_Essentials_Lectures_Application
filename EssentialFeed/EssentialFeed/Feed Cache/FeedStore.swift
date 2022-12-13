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
    
    func deleteItems(completion: @escaping (Error?) -> Void)
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping (Error?) -> Void)
}
