//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Василий Клецкин on 28.12.2022.
//

import XCTest
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
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
    
    func test_userInitiatedLoading_triggersLoading() {
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedLoading()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedLoading()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (_, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isLoadingIndicatorActive)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorOnLoadEnd() {
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        
        loader.complete()
        
        XCTAssertFalse(sut.isLoadingIndicatorActive)
    }
    
    func test_userInitiatedLoading_showLoadingIndicator() {
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.complete(at: 0)
        
        sut.simulateUserInitiatedLoading()
        
        XCTAssertTrue(sut.isLoadingIndicatorActive)
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
