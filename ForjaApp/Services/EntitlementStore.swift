//
//  EntitlementStore.swift
//  ForjaApp
//

import Foundation
import Combine

@MainActor
final class EntitlementStore: ObservableObject {
    static let shared = EntitlementStore()

    @Published private(set) var isStoreKitSubscribed = false
    @Published private(set) var hasHardcoreUnlock = false

    private init() {}

    func applyStoreKit(isSubscribed: Bool, hasHardcore: Bool) {
        isStoreKitSubscribed = isSubscribed
        hasHardcoreUnlock = hasHardcore
        if hasHardcore {
            InventoryManager.shared.unlockHardcore()
        }
    }

    var isTrialActive: Bool {
        guard let start = InventoryManager.shared.progress.trialStartedAt else { return false }
        let end = Calendar.current.date(byAdding: .day, value: EntitlementLimits.trialDurationDays, to: start) ?? start
        return Date() < end
    }

    var trialDaysRemaining: Int {
        guard let start = InventoryManager.shared.progress.trialStartedAt else { return 0 }
        let end = Calendar.current.date(byAdding: .day, value: EntitlementLimits.trialDurationDays, to: start) ?? start
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0)
    }

    var isPremium: Bool {
        isStoreKitSubscribed || isTrialActive
    }

    var canUseUnlimitedSessions: Bool { isPremium }
    var canUseAdvancedStats: Bool { isPremium }
    var canUsePremiumSkins: Bool { isPremium }
    var canUseUnlimitedBackup: Bool { isPremium }
    var canUseExtraGrace: Bool { isPremium }

    var dailySessionLimit: Int {
        canUseUnlimitedSessions ? Int.max : EntitlementLimits.freeDailySessions
    }

    var maxGraceSeconds: Int {
        canUseExtraGrace ? EntitlementLimits.subscriberMaxGraceSeconds : EntitlementLimits.freeMaxGraceSeconds
    }

    var canEnableHardcore: Bool {
        hasHardcoreUnlock || InventoryManager.shared.progress.hasUnlockedHardcore || isPremium
    }

    func remainingSessionsToday(progress: UserProgress) -> Int {
        if canUseUnlimitedSessions { return Int.max }
        return max(0, EntitlementLimits.freeDailySessions - progress.sessionsToday)
    }

    func canStartSession(progress: UserProgress) -> Bool {
        remainingSessionsToday(progress: progress) > 0
    }
}
