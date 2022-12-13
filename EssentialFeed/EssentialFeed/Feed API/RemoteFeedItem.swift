//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 13.12.2022.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
