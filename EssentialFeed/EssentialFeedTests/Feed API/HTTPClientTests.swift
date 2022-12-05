//
//  HTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Василий Клецкин on 05.12.2022.
//

import XCTest
import EssentialFeed

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
        let sut = makeSut()
        
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
        
        let error = errorForStubbed(error: expectedError) as? NSError
        
        XCTAssertEqual(error?.code, expectedError.code)
        XCTAssertEqual(error?.domain, expectedError.domain)
    }
    
    func test_get_producesErrorOnInvalidResponses() {
        XCTAssertNotNil(errorForStubbed(data: nil, response: nil, error: nil))
        XCTAssertNotNil(errorForStubbed(data: nil, response: anyNonHTTPUrlResponse(), error: nil))
        XCTAssertNotNil(errorForStubbed(data: nil, response: anyHTTPUrlResponse(), error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: anyNonHTTPUrlResponse(), error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: anyHTTPUrlResponse(), error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: nil, error: anyNsError()))
        XCTAssertNotNil(errorForStubbed(data: anyData(), response: anyNonHTTPUrlResponse(), error: nil))
    }
    
    func test_get_producesHTTPResultOnValidResponse() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPUrlResponse()
        
        let (data, response) = responseForStubbed(data: expectedData, response: expectedResponse, error: nil)
        
        XCTAssertEqual(expectedData, data)
        XCTAssertEqual(expectedResponse.statusCode, response?.statusCode)
        XCTAssertEqual(expectedResponse.url, response?.url)
    }
    
    func test_get_producesHTTPResultOnHTTPResponseAndNilData() {
        let expectedResponse = anyHTTPUrlResponse()
        
        let (data, response) = responseForStubbed(data: nil, response: expectedResponse, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(data, emptyData)
        XCTAssertEqual(expectedResponse.statusCode, response?.statusCode)
        XCTAssertEqual(expectedResponse.url, response?.url)
    }
    // MARK: - Helpers
    
    private func errorForStubbed(data: Data? = nil, response: URLResponse? = nil, error: NSError?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultForStubbed(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected to get an errror", file: file, line: line)
            return nil
        }
    }
    
    private func responseForStubbed(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #filePath, line: UInt = #line) -> (Data?, HTTPURLResponse?) {
        let result = resultForStubbed(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected to succeed", file: file, line: line)
            return (nil, nil)
        }
    }
    
    private func resultForStubbed(data: Data?, response: URLResponse?, error: NSError?, file: StaticString = #filePath, line: UInt = #line) -> HTTPResponse {
        let sut = makeSut()
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "wait for getting from url")
        var receivedResult: HTTPResponse!
        sut.get(from: anyUrl()) { response in
            receivedResult = response
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func makeSut() -> HTTPClient {
        let sut = URLSessionHTTPClient()
        checkForMemoryLeaks(instance: sut)
        return sut
    }
    
    private func checkForMemoryLeaks(
        instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "\(String(describing: instance)) supposed to be not nil. Potentially memory leak.", file: file, line: line)
        }
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
