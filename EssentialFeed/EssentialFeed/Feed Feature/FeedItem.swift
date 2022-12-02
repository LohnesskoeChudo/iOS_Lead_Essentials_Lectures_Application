//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 01.12.2022.
//

import Foundation

public struct FeedItem: Equatable {
    public init(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageUrl: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
}
