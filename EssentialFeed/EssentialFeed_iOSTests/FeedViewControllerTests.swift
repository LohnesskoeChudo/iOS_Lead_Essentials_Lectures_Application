//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Василий Клецкин on 28.12.2022.
//

import XCTest
import EssentialFeed
import EssentialFeed_iOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let loader = SpyLoader()
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedLoading()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedLoading()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isLoadingIndicatorActive, "Expected loading indicator once view is loaded")

        loader.complete(at: 0)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedLoading()
        XCTAssertTrue(sut.isLoadingIndicatorActive, "Expected loading indicator once user initiates a reload")

        loader.complete(at: 1)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once user initiated loading is completed")
    }
    
    // MARK: - Helpers
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (SpyLoader, FeedViewController) {
        let loader = SpyLoader()
        let sut = FeedViewController(loader: loader)
        checkForMemoryLeaks(instance: loader, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (loader, sut)
    }
    
    final class SpyLoader: FeedLoader  {
        private var completions: [(FeedLoader.Result) -> Void] = []
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        var loadCallCount: Int {
            completions.count
        }
        
        func complete(at index: Int = 0) {
            completions[index](.failure(anyNsError()))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedLoading() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
    var isLoadingIndicatorActive: Bool {
        refreshControl?.isRefreshing ?? false
    }
}
