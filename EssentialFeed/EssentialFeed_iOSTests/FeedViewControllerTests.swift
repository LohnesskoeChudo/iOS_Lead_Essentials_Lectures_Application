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
        let (loader, sut) = makeSut()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedLoading()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedLoading()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadFeedActions_showsLoadingIndicator() {
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isLoadingIndicatorActive, "Expected loading indicator once view is loaded")

        loader.completeWith(feed: [], at: 0)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedLoading()
        XCTAssertTrue(sut.isLoadingIndicatorActive, "Expected loading indicator once user initiates a reload")

        loader.completeWith(error: anyNsError(), at: 1)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once user initiated loading is completed")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "description", location: "location")
        let image1 = makeImage(description: "description")
        let image2 = makeImage(location: "location")
        let image3 = makeImage()
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        
        assert(sut: sut, isRendering: [])
        
        loader.completeWith(feed: [image0], at: 0)
        assert(sut: sut, isRendering: [image0])
        
        sut.simulateUserInitiatedLoading()
        loader.completeWith(feed: [image0, image1, image2, image3], at: 1)
        assert(sut: sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterStateOnError() {
        let feed = anyFeed()
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.completeWith(feed: feed)
        assert(sut: sut, isRendering: feed)
        
        sut.simulateUserInitiatedLoading()
        loader.completeWith(error: anyNsError())
        assert(sut: sut, isRendering: feed)
    }
    
    // MARK: - Helpers
    
    private func assert(sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.renderedViewsCount == feed.count else {
            return XCTFail("Expected \(feed.count) images but got \(sut.renderedViewsCount)")
        }
        XCTAssertEqual(sut.renderedViewsCount, feed.count, file: file, line: line)
        for (index, image) in feed.enumerated() {
            assert(sut: sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assert(sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        guard let feedImageView = sut.feedImageView(for: index) else {
            XCTFail("Unable to find feed image view.", file: file, line: line)
            return
        }
        let isShowingLocation = image.location != nil
        XCTAssertEqual(feedImageView.isShowingLocation, isShowingLocation, file: file, line: line)
        XCTAssertEqual(feedImageView.locationText, image.location, file: file, line: line)
        XCTAssertEqual(feedImageView.descriptionText, image.description, file: file, line: line)
    }
    
    private func anyFeed() -> [FeedImage] {
        let image = makeImage(description: "description")
        let anotherImage = makeImage(location: "location")
        return [image, anotherImage]
    }
            
    private func makeImage(id: UUID? = nil, description: String? = nil, location: String? = nil, url: URL? = nil) -> FeedImage {
        return FeedImage(id: id ?? UUID(), description: description, location: location, url: url ?? anyUrl())
    }
    
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
        
        func completeWith(feed: [FeedImage], at index: Int = 0) {
            completions[index](.success(feed))
        }
        
        func completeWith(error: Error, at index: Int = 0) {
            completions[index](.failure(error))
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
    
    var renderedViewsCount: Int {
        tableView.numberOfRows(inSection: 0)
    }
    
    func feedImageView(for index: Int) -> FeedImageCell? {
        tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: 0)) as? FeedImageCell
    }
}

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}
