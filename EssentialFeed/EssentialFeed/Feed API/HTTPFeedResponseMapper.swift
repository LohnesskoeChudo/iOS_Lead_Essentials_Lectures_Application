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
        
        var feedItems: [FeedItem] {
            items.map { $0.feedItem }
        }
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
    
    static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_Code, let root = decodeRoot(data: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feedItems)
    }
    
    static private func decodeRoot(data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
}
