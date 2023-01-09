//
//  FeedImageViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import EssentialFeed
import Foundation

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    typealias DataTransformer = (Data) -> Image?
    
    private let image: FeedImage
    private let loader: ImageDataLoader
    private let transform: DataTransformer
    private var task: ImageDataLoaderTask?
    
    var onLoadingStateChanged: Observer<Bool>?
    var onShouldRetryStateChanged: Observer<Bool>?
    var onImageLoaded: Observer<Image>?
    
    init(
        image: FeedImage,
        loader: ImageDataLoader,
        transform: @escaping DataTransformer
    ) {
        self.image = image
        self.loader = loader
        self.transform = transform
    }
    
    var description: String? {
        image.description
    }
    
    var location: String? {
        image.location
    }
    
    var needToPresentLocation: Bool {
        image.location != nil
    }
    
    func loadImageData() {
        onLoadingStateChanged?(true)
        task = loader.loadImageData(from: image.url) { [weak self] result in
            self?.onLoadingStateChanged?(false)
            self?.handle(result: result)
            self?.onLoadingStateChanged?(false)
        }
    }
    
    private func handle(result: ImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(transform) {
             onImageLoaded?(image)
         } else {
             onShouldRetryStateChanged?(true)
        }
    }
    
    func preload() {
        task = loader.loadImageData(from: image.url) { _ in }
    }
    
    func cancelPreload() {
        task?.cancel()
        task = nil
    }
}
