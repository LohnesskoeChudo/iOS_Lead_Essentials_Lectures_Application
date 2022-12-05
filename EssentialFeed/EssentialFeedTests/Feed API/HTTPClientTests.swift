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
    
    struct UnexpectedResponse: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedResponse()))
            }
        }.resume()
    }
}

final class HTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterception()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.endInterception()
    }
    
    func test_get_requestsWithCorrectUrl() {
        let url = anyUrl()
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "waiting for capturing url")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_receivesErrorOnError() {
        let expectedError = anyNsError()
        let sut = URLSessionHTTPClient()
        URLProtocolStub.stub(error: expectedError)
        
        let exp = expectation(description: "wait for getting from url")
        sut.get(from: anyUrl()) { response in
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
    }
    
    func test_get_producesErrorOnInvalidResponses() {
        XCTAssertNotNil(errorForStubbed(data: nil, response: nil, error: nil))
        XCTAssertNotNil(errorForStubbed(data: nil, response: anyHTTPUrlResponse(), error: nil))
        XCTAssertNotNil(errorForStubbed(data: nil, response: anyNonHTTPUrlResponse(), error: nil))
        XCTAssertNotNil(errorForStubbed(data: nil, response: anyHTTPUrlResponse(), error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: anyNonHTTPUrlResponse(), error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: anyHTTPUrlResponse(), error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: nil, error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: anyNonHTTPUrlResponse(), error: nil))
    }
    
    func test_get_producesHTTPResultOnValidResponse() {
        let data = anyData()
        let httpResponse = anyHTTPUrlResponse()
        let sut = URLSessionHTTPClient()
        URLProtocolStub.stub(data: data, response: httpResponse, error: nil)
        
        let exp = expectation(description: "wait for getting from url")
        sut.get(from: anyUrl()) { response in
            switch response {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.statusCode, httpResponse.statusCode)
                XCTAssertEqual(receivedResponse.url, httpResponse.url)
            default:
                XCTFail("Expected to succeed")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func errorForStubbed(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let sut = URLSessionHTTPClient()
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "wait for getting from url")
        var receivedError: Error?
        sut.get(from: anyUrl()) { response in
            switch response {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected to get an errror", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyUrl() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNsError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func anyHTTPUrlResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyNonHTTPUrlResponse() -> URLResponse {
        URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    
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
            let data: Data?
            let response: URLResponse?
            let error: NSError?
        }
        
        private static var stub: Stub?
        private static var requestObservation: ((URLRequest) -> Void)?
        
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: NSError?) {
            stub = Stub(data: data, response: response, error: error)
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
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
