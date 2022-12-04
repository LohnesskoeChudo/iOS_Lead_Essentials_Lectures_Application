//
//  HTTPFeedResponseMapper.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 04.12.2022.
//

import Foundation

enum HTTPFeedResponseMapper {
    struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    struct RemoteFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }
    
    private static let OK_Code = 200
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_Code else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let remoteItems = try JSONDecoder().decode(Root.self, from: data)
        return remoteItems.items.map { $0.feedItem }
    }
}
