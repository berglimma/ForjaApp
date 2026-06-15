//
//  InventoryManager.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Foundation
import Combine

@MainActor
final class InventoryManager: ObservableObject {
    static let shared = InventoryManager()

    @Published private(set) var progress: UserProgress

    private let storageKey = "forja.user.progress"
    private let firebaseManager = FirebaseManager.shared

    private init() {
        progress = Self.loadLocal()
        progress.rollPeriodsIfNeeded()
    }

    var forgedBars: Int { progress.forgedBars }

    func completeForge(barsEarned: Int, focusSeconds: Int) {
        progress.rollPeriodsIfNeeded()
        progress.forgedBars += barsEarned
        progress.totalSessions += 1
        progress.successfulSessions += 1
        progress.addFocusTime(seconds: focusSeconds)
        progress.currentStreak += 1
        progress.bestStreak = max(progress.bestStreak, progress.currentStreak)
        persist()
    }

    func failForge(focusSeconds: Int = 0, plannedSeconds: Int = 0) {
        progress.rollPeriodsIfNeeded()
        progress.totalSessions += 1
        progress.failedSessions += 1
        progress.currentStreak = 0
        progress.addUnfulfilledTime(seconds: max(0, plannedSeconds - focusSeconds))
        if focusSeconds > 0 {
            progress.addFocusTime(seconds: focusSeconds)
        }
        persist()
    }

    func purchase(item: ShopItem) -> Bool {
        guard progress.forgedBars >= item.price else { return false }

        progress.forgedBars -= item.price
        progress.ownedCollectibles.append(
            OwnedCollectible(id: UUID().uuidString, itemID: item.id, acquiredAt: Date())
        )
        persist()
        return true
    }

    func canAfford(_ item: ShopItem) -> Bool {
        progress.forgedBars >= item.price
    }

    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        progress.displayName = trimmed
        persist()
    }

    func updateWeeklyGoal(minutes: Int) {
        progress.weeklyGoalMinutes = max(15, min(600, minutes))
        persist()
    }

    func updateDailyGoal(minutes: Int) {
        progress.dailyGoalMinutes = max(5, min(480, minutes))
        persist()
    }

    func applyRemoteProgress(_ remote: UserProgress) {
        progress = remote
        progress.rollPeriodsIfNeeded()
        saveLocal()
    }

    private func persist() {
        saveLocal()
        Task {
            await firebaseManager.syncProgress(progress)
        }
    }

    private func saveLocal() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func loadLocal() -> UserProgress {
        guard
            let data = UserDefaults.standard.data(forKey: "forja.user.progress"),
            let decoded = try? JSONDecoder().decode(UserProgress.self, from: data)
        else {
            return .empty
        }
        return decoded
    }
}
