//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 01.12.2022.
//

import XCTest

final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    func load() {
        client.get(from: url)
    }
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
}

class HTTPClient {
    var requestedUrl: URL?
    
    func get(from url: URL) {
        requestedUrl = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_sut_doesNotRequestOnCreation() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClient()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsWithProperUrl() {
        let url = URL(string: "http://given-url.com")!
        let client = HTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrl, url)
    }
}
