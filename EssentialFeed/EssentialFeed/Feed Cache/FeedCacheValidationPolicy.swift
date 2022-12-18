//
//  FeedCacheValidationPolicy.swift
//  EssentialFeed
//
//  Created by Василий Клецкин on 18.12.2022.
//

import Foundation

enum FeedCacheValidationPolicy {
    static private let calendar = Calendar(identifier: .gregorian)
    
    static private var cacheMaxAgeInDays: Int { 7 }
    
    static func validate(date: Date, against timestamp: Date) -> Bool {
        guard let maxAge = calendar.date(byAdding: .day, value: cacheMaxAgeInDays, to: timestamp) else { return false }
        return date < maxAge
    }
}
