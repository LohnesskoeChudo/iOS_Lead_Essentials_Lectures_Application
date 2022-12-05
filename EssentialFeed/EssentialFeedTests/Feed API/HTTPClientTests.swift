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
    
    func test_get_requestsWithCorrectUrl() {
        URLProtocolStub.startInterception()
        let url = URL(string: "http://any-url.com")!
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "waiting for capturing url")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.endInterception()
    }
    
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
            stub = nil
            requestObservation = nil
        }
        
        private struct Stub {
            let error: NSError?
        }
        
        private static var stub: Stub?
        private static var requestObservation: ((URLRequest) -> Void)?
        
        static func stub(error: NSError, for url: URL) {
            stub = Stub(error: error)
        }
        
        static func observeRequests(_ completion: @escaping (URLRequest) -> Void) {
            requestObservation = completion
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObservation?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        
        override func startLoading() {
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
