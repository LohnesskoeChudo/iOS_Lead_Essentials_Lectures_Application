//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Василий Клецкин on 28.12.2022.
//

import XCTest
import EssentialFeed

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load() { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotTriggerLoading() {
        let loader = SpyLoader()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_triggersLoading() {
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
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
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
        
        var loadCallCount = 0
    }
}
