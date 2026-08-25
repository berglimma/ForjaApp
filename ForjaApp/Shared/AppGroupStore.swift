//
//  AppGroupStore.swift
//  ForjaApp
//

import Foundation

enum AppGroupID {
    static let suite = "group.com.forja.app"
    static let snapshotKey = "forja.widget.snapshot"
}

struct WidgetSnapshot: Codable, Equatable {
    var currentStreak: Int
    var bestStreak: Int
    var dailyFocusSeconds: Int
    var dailyGoalSeconds: Int
    var displayName: String
    var avatarEmoji: String
    var lifetimeBars: Int
    var isDailyGoalMet: Bool

    static let empty = WidgetSnapshot(
        currentStreak: 0,
        bestStreak: 0,
        dailyFocusSeconds: 0,
        dailyGoalSeconds: 3600,
        displayName: "Ferreiro",
        avatarEmoji: "⚒️",
        lifetimeBars: 0,
        isDailyGoalMet: false
    )

    var dailyProgress: Double {
        guard dailyGoalSeconds > 0 else { return 0 }
        return min(1, Double(dailyFocusSeconds) / Double(dailyGoalSeconds))
    }

    var remainingGoalLabel: String {
        let remaining = max(0, dailyGoalSeconds - dailyFocusSeconds)
        if remaining == 0 { return "Meta concluída" }
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)min restantes"
        }
        return "\(minutes) min restantes"
    }
}

enum WidgetBridge {
    static func save(_ snapshot: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: AppGroupID.suite),
              let data = try? JSONEncoder().encode(snapshot)
        else { return }
        defaults.set(data, forKey: AppGroupID.snapshotKey)
        defaults.synchronize()
    }

    static func load() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: AppGroupID.suite),
              let data = defaults.data(forKey: AppGroupID.snapshotKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }
}
