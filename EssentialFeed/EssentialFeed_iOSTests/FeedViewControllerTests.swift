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

        loader.complete(at: 0)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedLoading()
        XCTAssertTrue(sut.isLoadingIndicatorActive, "Expected loading indicator once user initiates a reload")

        loader.complete(at: 1)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once user initiated loading is completed")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "description", location: "location")
        let image1 = makeImage(description: "description")
        let image2 = makeImage(location: "location")
        let image3 = makeImage()
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.renderedViewsCount, 0)
        
        loader.complete(with: [image0], at: 0)
        XCTAssertEqual(sut.renderedViewsCount, 1)
        assert(sut: sut, hasViewConfiguredFor: image0, at: 0)
        
        sut.simulateUserInitiatedLoading()
        loader.complete(with: [image0, image1, image2, image3], at: 1)
        XCTAssertEqual(sut.renderedViewsCount, 4)
        assert(sut: sut, hasViewConfiguredFor: image0, at: 0)
        assert(sut: sut, hasViewConfiguredFor: image1, at: 1)
        assert(sut: sut, hasViewConfiguredFor: image2, at: 2)
        assert(sut: sut, hasViewConfiguredFor: image3, at: 3)
    }
    
    // MARK: - Helpers
    
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
        
        func complete(with images: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(images))
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
