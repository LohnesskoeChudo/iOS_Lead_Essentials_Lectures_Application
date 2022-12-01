//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 01.12.2022.
//

import XCTest

final class RemoteFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

class HTTPClient {
    var requestedUrl: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_sut_doesNotRequestOnCreation() throws {
        let client = HTTPClient()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedUrl)
    }
}
