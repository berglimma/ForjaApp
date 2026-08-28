//
//  InventoryManager.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Foundation
import Combine
import WidgetKit

@MainActor
final class InventoryManager: ObservableObject {
    static let shared = InventoryManager()

    @Published private(set) var progress: UserProgress

    private let storageKey = "forja.user.progress"
    private let firebaseManager = FirebaseManager.shared

    private init() {
        progress = Self.loadLocal()
        progress.rollPeriodsIfNeeded()
        saveLocal()
        publishWidget()
    }

    var forgedBars: Int { progress.forgedBars }
    var ore: Int { progress.forgedBars }
    var gems: Int { progress.gems }

    func completeForge(barsEarned: Int, focusSeconds: Int, countsTowardChallenge: Bool = true) {
        progress.rollPeriodsIfNeeded()
        progress.forgedBars += barsEarned
        if countsTowardChallenge {
            progress.lifetimeBars += barsEarned
            progress.weeklyBars += barsEarned
        }
        progress.sessionsToday += 1
        progress.totalSessions += 1
        progress.successfulSessions += 1
        progress.addFocusTime(seconds: focusSeconds)
        progress.recordSessionHour()
        progress.currentStreak += 1
        progress.bestStreak = max(progress.bestStreak, progress.currentStreak)
        persist()
        Task { await SocialService.shared.syncWeeklyTotals() }
    }

    func failForge(focusSeconds: Int = 0, plannedSeconds: Int = 0) {
        progress.rollPeriodsIfNeeded()
        progress.sessionsToday += 1
        progress.totalSessions += 1
        progress.failedSessions += 1
        progress.currentStreak = 0
        progress.recordSessionHour()
        progress.addUnfulfilledTime(seconds: max(0, plannedSeconds - focusSeconds))
        if focusSeconds > 0 {
            progress.addFocusTime(seconds: focusSeconds)
        }
        persist()
        Task { await SocialService.shared.syncWeeklyTotals() }
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

    func addGems(_ amount: Int) {
        guard amount > 0 else { return }
        progress.gems += amount
        persist()
    }

    func purchaseCosmetic(_ item: CosmeticItem) -> Bool {
        if item.requiresSubscription, !EntitlementStore.shared.isPremium {
            return false
        }
        if item.gemPrice > 0 {
            guard progress.gems >= item.gemPrice else { return false }
            progress.gems -= item.gemPrice
        }
        progress.grantCosmetic(item.id)
        persist()
        return true
    }

    func unlockSeasonalPack(_ season: CosmeticSeason) {
        let pack = CosmeticCatalog.seasonalPacks.first { $0.season == season }
        if let pack {
            for id in CosmeticCatalog.ownedIDs(from: pack) {
                progress.grantCosmetic(id)
            }
            persist()
        }
    }

    func unlockHardcore() {
        progress.hasUnlockedHardcore = true
        persist()
    }

    func equipCosmetic(_ item: CosmeticItem) {
        guard progress.ownsCosmetic(item.id) || (item.requiresSubscription && EntitlementStore.shared.isPremium) else { return }
        switch item.kind {
        case .anvilSkin:
            progress.equippedAnvilSkinID = item.id
        case .furnaceSkin:
            progress.equippedFurnaceSkinID = item.id
        case .shopTheme, .seasonalPack:
            progress.equippedShopThemeID = item.id
        }
        persist()
    }

    func selectAvatar(_ avatar: MedievalAvatar) {
        progress.selectedAvatarID = avatar.id
        persist()
        NotificationScheduler.reschedule(for: progress)
    }

    func setUsesAvatarAsProfilePhoto(_ enabled: Bool) {
        progress.usesAvatarAsProfilePhoto = enabled
        persist()
    }

    func updateGraceSeconds(_ seconds: Int) {
        let maxAllowed = EntitlementStore.shared.maxGraceSeconds
        progress.graceSeconds = max(0, min(maxAllowed, seconds))
        persist()
    }

    func setHardcoreEnabled(_ enabled: Bool) {
        guard !enabled || EntitlementStore.shared.canEnableHardcore else { return }
        progress.isHardcoreEnabled = enabled
        if enabled {
            progress.graceSeconds = 0
        } else if progress.graceSeconds == 0 {
            progress.graceSeconds = 5
        }
        persist()
    }

    func completeOnboarding() {
        progress.onboardingCompleted = true
        persist()
    }

    func clearAccountData() {
        progress = .empty
        progress.onboardingCompleted = true
        persist()
        ProfileImageStore.shared.delete()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        progress.notificationsEnabled = enabled
        persist()
        NotificationScheduler.reschedule(for: progress)
    }

    func canAffordCosmetic(_ item: CosmeticItem) -> Bool {
        if item.requiresSubscription { return EntitlementStore.shared.isPremium }
        if item.isDirectIAP { return false }
        return progress.gems >= item.gemPrice
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

    func rollPeriodsIfNeeded() {
        progress.rollPeriodsIfNeeded()
    }

    func applyRemoteProgress(_ remote: UserProgress) {
        progress = remote
        progress.rollPeriodsIfNeeded()
        saveLocal()
        publishWidget()
    }

    private func persist() {
        saveLocal()
        publishWidget()
        Task {
            await firebaseManager.syncProgress(progress)
        }
    }

    private func publishWidget() {
        WidgetBridge.save(
            WidgetSnapshot(
                currentStreak: progress.currentStreak,
                bestStreak: progress.bestStreak,
                dailyFocusSeconds: progress.dailyFocusSeconds,
                dailyGoalSeconds: progress.dailyGoalSeconds,
                displayName: progress.displayName,
                avatarImageName: progress.selectedAvatar.imageName,
                lifetimeBars: progress.lifetimeBars,
                isDailyGoalMet: progress.isDailyGoalMet
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
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
