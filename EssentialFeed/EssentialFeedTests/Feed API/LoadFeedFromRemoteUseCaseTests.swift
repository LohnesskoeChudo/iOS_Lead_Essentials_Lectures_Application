//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 01.12.2022.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestFromUrl() {
        let (_, client) = makeSut()
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsFromProperUrl() {
        let url = anyUrl()
        let (sut, client) = makeSut(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsFromProperUrlTwice() {
        let url = anyUrl()
        let (sut, client) = makeSut(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_receivesConnectivityErrorOnClientError() {
        let (sut, client) = makeSut()
        
        assert(sut: sut, equalTo: failure(.connectivity), when: {
            let clientError = anyNsError()
            client.complete(with: clientError)
        })
    }
    
    func test_load_receivesInvalidDataErrorOnNonOkStatusCode() {
        let (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            assert(sut: sut, equalTo: failure(.invalidData), when: {
                let jsonData = makeJsonData(from: [])
                client.complete(withCode: code, data: jsonData, at: index)
            })
        }
    }
    
    func test_load_receivesInvalidDataErrorOnInvalidJsonWithOkCode() {
        let (sut, client) = makeSut()
        
        assert(sut: sut, equalTo: failure(.invalidData), when: {
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
        let (image1, jsonItem1) = makeItem(
            id: UUID(),
            imageUrl: anyUrl()
        )
        let (image2, jsonItem2) = makeItem(
            id: UUID(),
            description: "item 2 description",
            location: "item 2 location",
            imageUrl: anyUrl()
        )
        let jsonItems = [jsonItem1, jsonItem2]
        let jsonData = makeJsonData(from: jsonItems)
        
        assert(sut: sut, equalTo: .success([image1, image2]), when: {
            client.complete(withCode: 200, data: jsonData)
        })
    }
    
    func test_load_doesNotReceiveResultAfterSutDealocation() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = .init(url: anyUrl(), client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { result in
            capturedResults.append(result)
        }
        sut = nil
        client.complete(with: NSError(domain: "any", code: 1))
        
        XCTAssert(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSut(
        url: URL = URL(string: "http://any-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        checkForMemoryLeaks(instance: client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedImage, json: [String: Any]) {
        let image = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageUrl
        )
        let jsonItem = [
            "id": image.id.uuidString,
            "description": image.description,
            "location": image.location,
            "image": image.url.absoluteString
        ].compactMapValues { $0 }
        return (image, jsonItem)
    }
    
    private func makeJsonData(from jsonItems: [[String: Any]]) -> Data {
        let root = [
            "items": jsonItems
        ]
        return try! JSONSerialization.data(withJSONObject: root)
    }
    
    private func assert(
        sut: RemoteFeedLoader,
        equalTo expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "waiting for load")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(
                    receivedItems, expectedItems,
                    "\(receivedItems) and \(expectedItems) supposed to be equal.",
                    file: file,
                    line: line
                )
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(
                    receivedError, expectedError,
                    "\(expectedError) and \(expectedError) supposed to be equal.",
                    file: file,
                    line: line
                )
            default:
                XCTFail(
                    "\(receivedResult) and \(expectedResult) supposed to be equal.",
                    file: file,
                    line: line
                )
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
                         
        var requestedUrls: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
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
            messages[index].completion(.success((data, response)))
        }
    }
}
