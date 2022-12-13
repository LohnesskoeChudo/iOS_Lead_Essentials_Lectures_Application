//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Василий Клецкин on 06.12.2022.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchesAccountData() {
        guard let images = imagesFromServer() else { return }
        
        XCTAssertEqual(images[0], expectedImage(at: 0))
        XCTAssertEqual(images[1], expectedImage(at: 1))
        XCTAssertEqual(images[2], expectedImage(at: 2))
        XCTAssertEqual(images[3], expectedImage(at: 3))
        XCTAssertEqual(images[4], expectedImage(at: 4))
        XCTAssertEqual(images[5], expectedImage(at: 5))
        XCTAssertEqual(images[6], expectedImage(at: 6))
        XCTAssertEqual(images[7], expectedImage(at: 7))
    }
    
    // MARK: - Helpers
    
    private func imagesFromServer(file: StaticString = #filePath, line: UInt = #line) -> [FeedImage]? {
        let sut = makeSut()
        
        var receivedItems: [FeedImage]?
        let exp = expectation(description: "Waiting for capturing from server")
        sut.load { result in
            switch result {
            case let .success(items):
                receivedItems = items
            case let .failure(error):
                XCTFail("expected to get result but got \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedItems
    }
    
    private func makeSut() -> RemoteFeedLoader {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let httpClient = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: url, client: httpClient)
        checkForMemoryLeaks(instance: loader)
        checkForMemoryLeaks(instance: httpClient)
        return loader
    }
    
    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
}
