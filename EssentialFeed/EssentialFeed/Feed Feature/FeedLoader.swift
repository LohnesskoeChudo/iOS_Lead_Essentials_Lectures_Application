//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 01.12.2022.
//

import Foundation

public enum FeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (FeedResult) -> Void)
}
