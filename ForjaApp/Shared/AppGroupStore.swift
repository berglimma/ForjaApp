//
//  AppGroupStore.swift
//  ForjaApp
//

import Foundation

enum AppGroupID {
    static let suite = "group.com.lindenbergbrito.forja"
    static let snapshotKey = "forja.widget.snapshot"
}

struct WidgetSnapshot: Codable, Equatable {
    var currentStreak: Int
    var bestStreak: Int
    var dailyFocusSeconds: Int
    var dailyGoalSeconds: Int
    var displayName: String
    var avatarImageName: String
    var lifetimeBars: Int
    var isDailyGoalMet: Bool
    var dailyGoalMinutes: Int
    var missionsCompleted: Int
    var missionsTotal: Int

    static let empty = WidgetSnapshot(
        currentStreak: 0,
        bestStreak: 0,
        dailyFocusSeconds: 0,
        dailyGoalSeconds: 3600,
        displayName: "Ferreiro",
        avatarImageName: "Avatar_smith",
        lifetimeBars: 0,
        isDailyGoalMet: false,
        dailyGoalMinutes: 60,
        missionsCompleted: 0,
        missionsTotal: 5
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
            return "\(hours)h \(minutes)min de \(dailyGoalMinutes) min"
        }
        return "\(minutes) min de \(dailyGoalMinutes) min"
    }

    var missionsLabel: String {
        "\(missionsCompleted)/\(missionsTotal) missões"
    }

    enum CodingKeys: String, CodingKey {
        case currentStreak, bestStreak, dailyFocusSeconds, dailyGoalSeconds
        case displayName, avatarImageName, lifetimeBars, isDailyGoalMet
        case dailyGoalMinutes, missionsCompleted, missionsTotal
    }

    init(
        currentStreak: Int,
        bestStreak: Int,
        dailyFocusSeconds: Int,
        dailyGoalSeconds: Int,
        displayName: String,
        avatarImageName: String,
        lifetimeBars: Int,
        isDailyGoalMet: Bool,
        dailyGoalMinutes: Int = 60,
        missionsCompleted: Int = 0,
        missionsTotal: Int = 5
    ) {
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.dailyFocusSeconds = dailyFocusSeconds
        self.dailyGoalSeconds = dailyGoalSeconds
        self.displayName = displayName
        self.avatarImageName = avatarImageName
        self.lifetimeBars = lifetimeBars
        self.isDailyGoalMet = isDailyGoalMet
        self.dailyGoalMinutes = dailyGoalMinutes
        self.missionsCompleted = missionsCompleted
        self.missionsTotal = missionsTotal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        bestStreak = try container.decode(Int.self, forKey: .bestStreak)
        dailyFocusSeconds = try container.decode(Int.self, forKey: .dailyFocusSeconds)
        dailyGoalSeconds = try container.decode(Int.self, forKey: .dailyGoalSeconds)
        displayName = try container.decode(String.self, forKey: .displayName)
        avatarImageName = try container.decodeIfPresent(String.self, forKey: .avatarImageName) ?? "Avatar_smith"
        lifetimeBars = try container.decode(Int.self, forKey: .lifetimeBars)
        isDailyGoalMet = try container.decode(Bool.self, forKey: .isDailyGoalMet)
        dailyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyGoalMinutes) ?? max(1, dailyGoalSeconds / 60)
        missionsCompleted = try container.decodeIfPresent(Int.self, forKey: .missionsCompleted) ?? 0
        missionsTotal = try container.decodeIfPresent(Int.self, forKey: .missionsTotal) ?? 5
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
