//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 01.12.2022.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try HTTPFeedResponseMapper.map(data: data, response: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

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
    
    static let OK_Code = 200
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_Code else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let remoteItems = try JSONDecoder().decode(Root.self, from: data)
        return remoteItems.items.map { $0.feedItem }
    }
}
