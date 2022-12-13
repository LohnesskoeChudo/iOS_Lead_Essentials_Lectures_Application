//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 13.12.2022.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public init(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        url: URL
    ) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
}
