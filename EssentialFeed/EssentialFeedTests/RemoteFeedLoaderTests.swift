//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 01.12.2022.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestFromUrl() {
        let (_, client) = makeSut()
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsFromProperUrl() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsFromProperUrlTwice() {
        let url = URL(string: "http://given-url.com")!
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_receivesConnectivityErrorOnClientError() {
        let (sut, client) = makeSut()
        
        assert(sut: sut, equalTo: .failure(.connectivity), when: {
            let clientError = NSError(domain: "any-domain", code: 1)
            client.complete(with: clientError)
        })
    }
    
    func test_load_receivesInvalidDataErrorOnNonOkStatusCode() {
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            assert(sut: sut, equalTo: .failure(.invalidData), when: {
                client.complete(withCode: code, at: index)
            })
        }
    }
    
    func test_load_receivesInvalidDataErrorOnInvalidJsonWithOkCode() {
        let (sut, client) = makeSut()
        
        assert(sut: sut, equalTo: .failure(.invalidData), when: {
            let invalidData = Data("invalid data".utf8)
            client.complete(withCode: 200, data: invalidData)
        })
    }
    
    func test_load_receivesEmptyArrayOnEmptyJSONAndOkCode() {
        let (sut, client) = makeSut()
        
        assert(sut: sut, equalTo: .success([]), when: {
            let emptyJson = Data("{ \"items\": [] }".utf8)
            client.complete(withCode: 200, data: emptyJson)
        })
    }
    
    func test_load_receivesFeedItemsOnNonEmptyJSONAndOkCode() {
        let (sut, client) = makeSut()
        let item1 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageUrl: URL(string: "http://some-url.com")!
        )
        let jsonItem1 = [
            "id": item1.id.uuidString,
            "image": item1.imageUrl.absoluteString
        ]
        let item2 = FeedItem(
            id: UUID(),
            description: "item 2 description",
            location: "item 2 location",
            imageUrl: URL(string: "http://some-url.com")!
        )
        let jsonItem2 = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageUrl.absoluteString
        ].compactMapValues { $0 }
        let root = [
            "items": [jsonItem1, jsonItem2]
        ]
        
        assert(sut: sut, equalTo: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: root)
            client.complete(withCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSut(url: URL = URL(string: "http://any-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func assert(
        sut: RemoteFeedLoader,
        equalTo result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { result in
            capturedResults.append(result)
        }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPResponse) -> Void)]()
                         
        var requestedUrls: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
