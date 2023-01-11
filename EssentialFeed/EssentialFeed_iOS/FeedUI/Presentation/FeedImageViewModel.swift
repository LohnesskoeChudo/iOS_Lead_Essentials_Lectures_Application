//
//  FeedImageViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Василий Клецкин on 11.01.2023.
//

struct FeedImageViewModel<Image> {
    let image: Image?
    let description: String?
    let location: String?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var needToPresentLocation: Bool {
        location != nil
    }
}
