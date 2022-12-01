//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 01.12.2022.
//

import Foundation

enum FeedResult {
    case success(FeedItem)
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: (FeedResult) -> Void)
}
