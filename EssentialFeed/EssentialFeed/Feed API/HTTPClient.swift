//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 01.12.2022.
//

import Foundation

public enum HTTPResponse {
    case failure(Error)
    case success(Data, HTTPURLResponse)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void)
}
