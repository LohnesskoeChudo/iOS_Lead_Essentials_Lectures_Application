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

        loader.completeFeedLoadingWith(feed: [], at: 0)
        XCTAssertFalse(sut.isLoadingIndicatorActive, "Expected no loading indicator once loading is completed")

        sut.simulateUserInitiatedLoading()
        XCTAssertTrue(sut.isLoadingIndicatorActive, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoadingWith(error: anyNsError(), at: 1)
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
        
        loader.completeFeedLoadingWith(feed: [image0], at: 0)
        assert(sut: sut, isRendering: [image0])
        
        sut.simulateUserInitiatedLoading()
        assert(sut: sut, isRendering: [image0])
        
        loader.completeFeedLoadingWith(feed: [image0, image1, image2, image3], at: 1)
        assert(sut: sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterStateOnError() {
        let feed = anyFeed()
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWith(feed: feed)
        assert(sut: sut, isRendering: feed)
        
        sut.simulateUserInitiatedLoading()
        loader.completeFeedLoadingWith(error: anyNsError())
        assert(sut: sut, isRendering: feed)
    }
    
    func test_feedImageBecomeVisible_loadsImageDataFromUrl() {
        let image0 = makeImage(url: URL(string: "http://image-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://image-url-1.com")!)
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWith(feed: [image0, image1])
        XCTAssertEqual(loader.imageDataUrls, [], "We don't want to load image data just after the feed has been loaded. We are waiting for feed image views become visible")
        
        sut.simulateFeedImageViewBecomeVisible(at: 0)
        XCTAssertEqual(loader.imageDataUrls, [image0.url])
        
        sut.simulateFeedImageViewBecomeVisible(at: 1)
        XCTAssertEqual(loader.imageDataUrls, [image0.url, image1.url])
    }
    
    func test_feedImageViewBecomeNonVisible_cancelsImageDataLoading() {
        let image0 = makeImage(url: URL(string: "http://image-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://image-url-1.com")!)
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWith(feed: [image0, image1])
        XCTAssertEqual(loader.cancelledImageDataUrls, [])
        
        sut.simulateFeedImageViewBecomeNonVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageDataUrls, [image0.url])
        
        sut.simulateFeedImageViewBecomeNonVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageDataUrls, [image0.url, image1.url])
    }
    
    func test_feedImageDataLoadingIndicator_isVisibleWhileLoadingImage() {
        let image0 = makeImage(url: URL(string: "http://image-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://image-url-1.com")!)
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWith(feed: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewBecomeVisible(at: 0)
        let view1 = sut.simulateFeedImageViewBecomeVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageDataLoadingWithSuccess(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromUrl() {
        let image0 = makeImage(url: URL(string: "http://image-url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://image-url-1.com")!)
        let (loader, sut) = makeSut()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWith(feed: [image0, image1])
        let view0 = sut.simulateFeedImageViewBecomeVisible(at: 0)
        let view1 = sut.simulateFeedImageViewBecomeVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, nil)
        XCTAssertEqual(view1?.renderedImage, nil)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageDataLoadingWithSuccess(data: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, nil)
        
        let imageData1 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageDataLoadingWithSuccess(data: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0)
        XCTAssertEqual(view1?.renderedImage, imageData1)
    }
    
    // MARK: - Helpers
    
    private func assert(sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.renderedViewsCount == feed.count else {
            return XCTFail("Expected \(feed.count) images but got \(sut.renderedViewsCount)", file: file, line: line)
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
        let sut = FeedViewController(feedLoader: loader, imageDataLoader: loader)
        checkForMemoryLeaks(instance: loader, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (loader, sut)
    }
    
    final class SpyLoader: FeedLoader, ImageDataLoader  {
        // MARK: FeedLoader
        
        private var feedLoadCompletions: [(FeedLoader.Result) -> Void] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedLoadCompletions.append(completion)
        }
        
        var loadCallCount: Int {
            feedLoadCompletions.count
        }
        
        func completeFeedLoadingWith(feed: [FeedImage], at index: Int = 0) {
            feedLoadCompletions[index](.success(feed))
        }
        
        func completeFeedLoadingWith(error: Error, at index: Int = 0) {
            feedLoadCompletions[index](.failure(error))
        }
        
        // MARK: ImageDataLoader
        
        var imageDataLoadingRequests: [(url: URL, completion: (ImageDataLoader.Result) -> Void)] = []
        var cancelledImageDataUrls: [URL] = []
        var imageDataUrls: [URL] { imageDataLoadingRequests.map { $0.url}}
        
        func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageDataLoadingRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageDataUrls.append(url) }
        }
        
        func completeImageDataLoadingWithSuccess(data: Data = Data(), at index: Int) {
            imageDataLoadingRequests[index].completion(.success(data))
        }
        
        func completeImageDataLoadingWithError(at index: Int) {
            imageDataLoadingRequests[index].completion(.failure(anyNsError()))
        }
    }
    
    struct TaskSpy: ImageDataLoaderTask {
        let cancelHandler: () -> Void
        
        func cancel() {
            cancelHandler()
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
    
    @discardableResult
    func simulateFeedImageViewBecomeVisible(at index: Int) -> FeedImageCell? {
        feedImageView(for: index)
    }
    
    func simulateFeedImageViewBecomeNonVisible(at index: Int) {
        let feedImageView = simulateFeedImageViewBecomeVisible(at: index)!
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: 0)
        delegate?.tableView?(tableView, didEndDisplaying: feedImageView, forRowAt: indexPath)
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
    
    var isShowingLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
         format.scale = 1

         return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
             color.setFill()
             rendererContext.fill(rect)
         }
    }
}
