//
//  Helpers.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 06.12.2022.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func checkForMemoryLeaks(
        instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "\(String(describing: instance)) supposed to be not nil. Potentially memory leak.", file: file, line: line)
        }
    }
    
    func anyUrl() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyNsError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func anyFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage(), uniqueImage()]
        let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (models, locals)
    }
    
    func uniqueImage() -> FeedImage {
        FeedImage(
            id: UUID(),
            description: "any description",
            location: "any location",
            url: anyUrl()
        )
    }
}
