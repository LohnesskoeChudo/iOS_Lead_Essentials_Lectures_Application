//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 17.12.2022.
//

import EssentialFeed
import Foundation

func anyFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage(), uniqueImage()]
    let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, locals)
}

func uniqueImage() -> FeedImage {
    FeedImage(
        id: UUID(),
        description: "any description",
        location: "any location",
        url: anyUrl()
    )
}
