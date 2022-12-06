//
//  Helpers.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 06.12.2022.
//

import XCTest

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
}
