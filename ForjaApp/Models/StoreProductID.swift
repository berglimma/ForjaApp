//
//  StoreProductID.swift
//  ForjaApp
//

import Foundation

enum StoreProductID {
    static let monthly = "com.forja.subscription.monthly"
    static let yearly = "com.forja.subscription.yearly"
    static let gemsSmall = "com.forja.gems.small"
    static let gemsMedium = "com.forja.gems.medium"
    static let gemsLarge = "com.forja.gems.large"
    static let packHalloween = "com.forja.pack.halloween"
    static let packNatal = "com.forja.pack.natal"
    static let hardcore = "com.forja.unlock.hardcore"

    static let subscriptionIDs: Set<String> = [monthly, yearly]
    static let gemIDs: Set<String> = [gemsSmall, gemsMedium, gemsLarge]
    static let seasonalIDs: Set<String> = [packHalloween, packNatal]
    static let all: [String] = [
        monthly, yearly, gemsSmall, gemsMedium, gemsLarge, packHalloween, packNatal, hardcore
    ]

    static func gemAmount(for productID: String) -> Int {
        switch productID {
        case gemsSmall: return 40
        case gemsMedium: return 110
        case gemsLarge: return 300
        default: return 0
        }
    }
}

enum EntitlementLimits {
    static let freeDailySessions = 8
    static let freeMaxGraceSeconds = 5
    static let subscriberMaxGraceSeconds = 20
    static let trialDurationDays = 7
}
