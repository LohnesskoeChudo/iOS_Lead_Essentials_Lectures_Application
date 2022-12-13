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
    
    private static let OK_Code = 200
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_Code, let root = decodeRoot(data: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
    static private func decodeRoot(data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
}
