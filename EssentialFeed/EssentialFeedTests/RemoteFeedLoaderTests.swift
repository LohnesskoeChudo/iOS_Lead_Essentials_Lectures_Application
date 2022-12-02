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
        let url = anyUrl
        let (sut, client) = makeSut(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsFromProperUrlTwice() {
        let url = anyUrl
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
                let jsonData = makeJsonData(from: [])
                client.complete(withCode: code, data: jsonData, at: index)
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
        let (item1, jsonItem1) = makeItem(
            id: UUID(),
            imageUrl: anyUrl
        )
        let (item2, jsonItem2) = makeItem(
            id: UUID(),
            description: "item 2 description",
            location: "item 2 location",
            imageUrl: anyUrl
        )
        let jsonItems = [jsonItem1, jsonItem2]
        let jsonData = makeJsonData(from: jsonItems)
        
        assert(sut: sut, equalTo: .success([item1, item2]), when: {
            client.complete(withCode: 200, data: jsonData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSut(url: URL = URL(string: "http://any-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageUrl: imageUrl
        )
        let jsonItem = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageUrl.absoluteString
        ].compactMapValues { $0 }
        return (item, jsonItem)
    }
    
    private func makeJsonData(from jsonItems: [[String: Any]]) -> Data {
        let root = [
            "items": jsonItems
        ]
        return try! JSONSerialization.data(withJSONObject: root)
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
    
    private var anyUrl: URL {
        URL(string: "http://given-url.com")!
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
