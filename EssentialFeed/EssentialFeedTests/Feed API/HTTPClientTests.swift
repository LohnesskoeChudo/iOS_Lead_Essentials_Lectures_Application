//
//  HTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 05.12.2022.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class HTTPClientTests: XCTestCase {
    
    func test_get_receivesErrorOnError() {
        URLProtocolStub.startInterception()
        let url = URL(string: "http://any-url.com")!
        let expectedError = NSError(domain: "any", code: 1)
        let sut = URLSessionHTTPClient()
        URLProtocolStub.stub(error: expectedError, for: url)
        
        let exp = expectation(description: "wait for getting from url")
        sut.get(from: url) { response in
            switch response {
            case let .failure(error as NSError):
                XCTAssertEqual(error.code, expectedError.code)
                XCTAssertEqual(error.domain, expectedError.domain)
            default:
                XCTFail("Expected to get an errror")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.endInterception()
    }
    
    // MARK: - Helpers
    
    final class URLProtocolStub: URLProtocol {
        
        static func startInterception() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func endInterception() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        private struct Stub {
            let error: NSError?
        }
        
        private static var stubs = [URL: Stub]()
        
        static func stub(error: NSError, for url: URL) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        
        override func startLoading() {
            guard let url = request.url else { return }
            if let error = Self.stubs[url]?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
