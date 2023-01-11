//
//  FeedImageViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 09.01.2023.
//

import EssentialFeed
import Foundation

protocol FeedImageView {
    associatedtype Image
    func display(viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<Image, View: FeedImageView> where View.Image == Image {
    typealias DataTransformer = (Data) -> Image?
    
    private let model: FeedImage
    private let transform: DataTransformer
    private let view: View
    
    init(
        view: View,
        model: FeedImage,
        transform: @escaping DataTransformer
    ) {
        self.view = view
        self.model = model
        self.transform = transform
    }
    
    func didLoadingStarted() {
        let viewModel = FeedImageViewModel<Image>(
            image: nil,
            description: model.description,
            location: model.location,
            isLoading: true,
            shouldRetry: false
        )
        view.display(viewModel: viewModel)
    }
    
    func didReceive(image data: Data) {
        let image = transform(data)
        let viewModel = FeedImageViewModel<Image>(
            image: image,
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: image == nil
        )
        view.display(viewModel: viewModel)
    }
    
    func didReceive(error: Error) {
        let viewModel = FeedImageViewModel<Image>(
            image: nil,
            description: model.description,
            location: model.location,
            isLoading: false,
            shouldRetry: true
        )
        view.display(viewModel: viewModel)
    }
}
