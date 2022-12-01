//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 01.12.2022.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_sut_doesNotRequestOnCreation() {
        let (_, client) = makeSut()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestsWithProperUrl() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    // MARK: - Helpers
    
    private func makeSut(url: URL = URL(string: "http://any-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var requestedUrl: URL?
        
        func get(from url: URL) {
            requestedUrl = url
        }
    }
}
