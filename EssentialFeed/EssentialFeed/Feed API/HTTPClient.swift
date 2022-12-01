//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 01.12.2022.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}
