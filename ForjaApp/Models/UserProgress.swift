//
//  UserProgress.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Foundation

struct UserProgress: Codable, Equatable {
    var forgedBars: Int
    var ownedCollectibles: [OwnedCollectible]
    var totalSessions: Int
    var successfulSessions: Int
    var failedSessions: Int
    var totalFocusSeconds: Int
    var unfulfilledFocusSeconds: Int
    var currentStreak: Int
    var bestStreak: Int
    var displayName: String
    var dailyGoalMinutes: Int
    var dailyFocusSeconds: Int
    var dayOfYear: Int
    var dayCalendarYear: Int
    var weeklyGoalMinutes: Int
    var weeklyFocusSeconds: Int
    var weekOfYear: Int
    var calendarYear: Int
    var gems: Int
    var lifetimeBars: Int
    var weeklyBars: Int
    var sessionsToday: Int
    var graceSeconds: Int
    var isHardcoreEnabled: Bool
    var selectedAvatarID: String
    var equippedAnvilSkinID: String
    var equippedFurnaceSkinID: String
    var equippedShopThemeID: String
    var ownedCosmeticIDs: [String]
    var weekdayFocusSeconds: [Int]
    var hourlySessionCounts: [Int]
    var onboardingCompleted: Bool
    var trialStartedAt: Date?
    var hasUnlockedHardcore: Bool
    var notificationsEnabled: Bool

    static let empty = UserProgress(
        forgedBars: 0,
        ownedCollectibles: [],
        totalSessions: 0,
        successfulSessions: 0,
        failedSessions: 0,
        totalFocusSeconds: 0,
        unfulfilledFocusSeconds: 0,
        currentStreak: 0,
        bestStreak: 0,
        displayName: "Ferreiro",
        dailyGoalMinutes: 60,
        dailyFocusSeconds: 0,
        dayOfYear: Self.currentDayOfYear(),
        dayCalendarYear: Self.currentDayCalendarYear(),
        weeklyGoalMinutes: 300,
        weeklyFocusSeconds: 0,
        weekOfYear: Self.currentWeekOfYear(),
        calendarYear: Self.currentCalendarYear(),
        gems: 0,
        lifetimeBars: 0,
        weeklyBars: 0,
        sessionsToday: 0,
        graceSeconds: 5,
        isHardcoreEnabled: false,
        selectedAvatarID: MedievalAvatar.default.id,
        equippedAnvilSkinID: CosmeticCatalog.defaultAnvilID,
        equippedFurnaceSkinID: CosmeticCatalog.defaultFurnaceID,
        equippedShopThemeID: CosmeticCatalog.defaultThemeID,
        ownedCosmeticIDs: [
            CosmeticCatalog.defaultAnvilID,
            CosmeticCatalog.defaultFurnaceID,
            CosmeticCatalog.defaultThemeID
        ],
        weekdayFocusSeconds: Array(repeating: 0, count: 7),
        hourlySessionCounts: Array(repeating: 0, count: 24),
        onboardingCompleted: false,
        trialStartedAt: nil,
        hasUnlockedHardcore: false,
        notificationsEnabled: false
    )

    var ore: Int { forgedBars }
    var dailyGoalSeconds: Int { dailyGoalMinutes * 60 }
    var weeklyGoalSeconds: Int { weeklyGoalMinutes * 60 }

    var dailyGoalProgress: Double {
        guard dailyGoalSeconds > 0 else { return 0 }
        return min(1, Double(dailyFocusSeconds) / Double(dailyGoalSeconds))
    }

    var weeklyGoalProgress: Double {
        guard weeklyGoalSeconds > 0 else { return 0 }
        return min(1, Double(weeklyFocusSeconds) / Double(weeklyGoalSeconds))
    }

    var isDailyGoalMet: Bool { dailyFocusSeconds >= dailyGoalSeconds }
    var isWeeklyGoalMet: Bool { weeklyFocusSeconds >= weeklyGoalSeconds }

    var selectedAvatar: MedievalAvatar {
        MedievalAvatar.avatar(for: selectedAvatarID)
    }

    var peakHour: Int {
        guard let maxCount = hourlySessionCounts.max(), maxCount > 0 else { return 9 }
        return hourlySessionCounts.firstIndex(of: maxCount) ?? 9
    }

    var peakWeekdayIndex: Int {
        guard let maxSeconds = weekdayFocusSeconds.max(), maxSeconds > 0 else {
            return Self.mondayFirstWeekdayIndex(from: Date())
        }
        return weekdayFocusSeconds.firstIndex(of: maxSeconds) ?? 0
    }

    var successRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(successfulSessions) / Double(totalSessions)
    }

    var chartSegments: [FocusChartSegment] {
        [
            FocusChartSegment(
                id: "fulfilled",
                title: "Foco cumprido",
                seconds: totalFocusSeconds,
                colorHex: "#F6AD55"
            ),
            FocusChartSegment(
                id: "unfulfilled",
                title: "Foco não cumprido",
                seconds: unfulfilledFocusSeconds,
                colorHex: "#E53E3E"
            )
        ]
    }

    func ownsCosmetic(_ id: String) -> Bool {
        ownedCosmeticIDs.contains(id)
    }

    mutating func grantCosmetic(_ id: String) {
        if !ownedCosmeticIDs.contains(id) {
            ownedCosmeticIDs.append(id)
        }
    }

    mutating func rollDayIfNeeded(now: Date = Date()) {
        let day = Self.dayOfYear(from: now)
        let year = Self.dayCalendarYear(from: now)
        if day != dayOfYear || year != dayCalendarYear {
            dailyFocusSeconds = 0
            sessionsToday = 0
            dayOfYear = day
            dayCalendarYear = year
        }
    }

    mutating func rollWeekIfNeeded(now: Date = Date()) {
        let week = Self.weekOfYear(from: now)
        let year = Self.calendarYear(from: now)
        if week != weekOfYear || year != calendarYear {
            weeklyFocusSeconds = 0
            weeklyBars = 0
            weekdayFocusSeconds = Array(repeating: 0, count: 7)
            weekOfYear = week
            calendarYear = year
        }
    }

    mutating func rollPeriodsIfNeeded(now: Date = Date()) {
        rollDayIfNeeded(now: now)
        rollWeekIfNeeded(now: now)
    }

    mutating func addFocusTime(seconds: Int, now: Date = Date()) {
        rollPeriodsIfNeeded(now: now)
        totalFocusSeconds += seconds
        dailyFocusSeconds += seconds
        weeklyFocusSeconds += seconds
        let index = Self.mondayFirstWeekdayIndex(from: now)
        if weekdayFocusSeconds.count != 7 {
            weekdayFocusSeconds = Array(repeating: 0, count: 7)
        }
        weekdayFocusSeconds[index] += seconds
    }

    mutating func addUnfulfilledTime(seconds: Int) {
        guard seconds > 0 else { return }
        unfulfilledFocusSeconds += seconds
    }

    mutating func recordSessionHour(now: Date = Date()) {
        if hourlySessionCounts.count != 24 {
            hourlySessionCounts = Array(repeating: 0, count: 24)
        }
        let hour = Calendar.current.component(.hour, from: now)
        hourlySessionCounts[hour] += 1
    }

    static func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes) min"
    }

    func ownedCount(for itemID: String) -> Int {
        ownedCollectibles.filter { $0.itemID == itemID }.count
    }

    static func weekdayLabel(index: Int) -> String {
        ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"][max(0, min(6, index))]
    }

    static func weekdayFullLabel(index: Int) -> String {
        ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"][max(0, min(6, index))]
    }

    static func mondayFirstWeekdayIndex(from date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        return (weekday + 5) % 7
    }

    private static func currentDayOfYear() -> Int {
        dayOfYear(from: Date())
    }

    private static func currentDayCalendarYear() -> Int {
        dayCalendarYear(from: Date())
    }

    private static func currentWeekOfYear() -> Int {
        weekOfYear(from: Date())
    }

    private static func currentCalendarYear() -> Int {
        calendarYear(from: Date())
    }

    static func dayOfYear(from date: Date) -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    static func dayCalendarYear(from date: Date) -> Int {
        Calendar.current.component(.year, from: date)
    }

    static func weekOfYear(from date: Date) -> Int {
        Calendar.current.component(.weekOfYear, from: date)
    }

    static func calendarYear(from date: Date) -> Int {
        Calendar.current.component(.yearForWeekOfYear, from: date)
    }

    enum CodingKeys: String, CodingKey {
        case forgedBars, ownedCollectibles, totalSessions, successfulSessions, failedSessions
        case totalFocusSeconds, unfulfilledFocusSeconds, currentStreak, bestStreak, displayName
        case dailyGoalMinutes, dailyFocusSeconds, dayOfYear, dayCalendarYear
        case weeklyGoalMinutes, weeklyFocusSeconds, weekOfYear, calendarYear
        case gems, lifetimeBars, weeklyBars, sessionsToday, graceSeconds, isHardcoreEnabled
        case selectedAvatarID, equippedAnvilSkinID, equippedFurnaceSkinID, equippedShopThemeID
        case ownedCosmeticIDs, weekdayFocusSeconds, hourlySessionCounts
        case onboardingCompleted, trialStartedAt, hasUnlockedHardcore, notificationsEnabled
    }

    init(
        forgedBars: Int,
        ownedCollectibles: [OwnedCollectible],
        totalSessions: Int,
        successfulSessions: Int,
        failedSessions: Int,
        totalFocusSeconds: Int,
        unfulfilledFocusSeconds: Int,
        currentStreak: Int,
        bestStreak: Int,
        displayName: String,
        dailyGoalMinutes: Int,
        dailyFocusSeconds: Int,
        dayOfYear: Int,
        dayCalendarYear: Int,
        weeklyGoalMinutes: Int,
        weeklyFocusSeconds: Int,
        weekOfYear: Int,
        calendarYear: Int,
        gems: Int,
        lifetimeBars: Int,
        weeklyBars: Int,
        sessionsToday: Int,
        graceSeconds: Int,
        isHardcoreEnabled: Bool,
        selectedAvatarID: String,
        equippedAnvilSkinID: String,
        equippedFurnaceSkinID: String,
        equippedShopThemeID: String,
        ownedCosmeticIDs: [String],
        weekdayFocusSeconds: [Int],
        hourlySessionCounts: [Int],
        onboardingCompleted: Bool,
        trialStartedAt: Date?,
        hasUnlockedHardcore: Bool,
        notificationsEnabled: Bool
    ) {
        self.forgedBars = forgedBars
        self.ownedCollectibles = ownedCollectibles
        self.totalSessions = totalSessions
        self.successfulSessions = successfulSessions
        self.failedSessions = failedSessions
        self.totalFocusSeconds = totalFocusSeconds
        self.unfulfilledFocusSeconds = unfulfilledFocusSeconds
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.displayName = displayName
        self.dailyGoalMinutes = dailyGoalMinutes
        self.dailyFocusSeconds = dailyFocusSeconds
        self.dayOfYear = dayOfYear
        self.dayCalendarYear = dayCalendarYear
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.weeklyFocusSeconds = weeklyFocusSeconds
        self.weekOfYear = weekOfYear
        self.calendarYear = calendarYear
        self.gems = gems
        self.lifetimeBars = lifetimeBars
        self.weeklyBars = weeklyBars
        self.sessionsToday = sessionsToday
        self.graceSeconds = graceSeconds
        self.isHardcoreEnabled = isHardcoreEnabled
        self.selectedAvatarID = selectedAvatarID
        self.equippedAnvilSkinID = equippedAnvilSkinID
        self.equippedFurnaceSkinID = equippedFurnaceSkinID
        self.equippedShopThemeID = equippedShopThemeID
        self.ownedCosmeticIDs = ownedCosmeticIDs
        self.weekdayFocusSeconds = weekdayFocusSeconds
        self.hourlySessionCounts = hourlySessionCounts
        self.onboardingCompleted = onboardingCompleted
        self.trialStartedAt = trialStartedAt
        self.hasUnlockedHardcore = hasUnlockedHardcore
        self.notificationsEnabled = notificationsEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = UserProgress.empty
        forgedBars = try container.decodeIfPresent(Int.self, forKey: .forgedBars) ?? 0
        ownedCollectibles = try container.decodeIfPresent([OwnedCollectible].self, forKey: .ownedCollectibles) ?? []
        totalSessions = try container.decodeIfPresent(Int.self, forKey: .totalSessions) ?? 0
        successfulSessions = try container.decodeIfPresent(Int.self, forKey: .successfulSessions) ?? 0
        failedSessions = try container.decodeIfPresent(Int.self, forKey: .failedSessions) ?? 0
        totalFocusSeconds = try container.decodeIfPresent(Int.self, forKey: .totalFocusSeconds) ?? 0
        unfulfilledFocusSeconds = try container.decodeIfPresent(Int.self, forKey: .unfulfilledFocusSeconds) ?? 0
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        bestStreak = try container.decodeIfPresent(Int.self, forKey: .bestStreak) ?? 0
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? "Ferreiro"
        dailyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyGoalMinutes) ?? 60
        dailyFocusSeconds = try container.decodeIfPresent(Int.self, forKey: .dailyFocusSeconds) ?? 0
        dayOfYear = try container.decodeIfPresent(Int.self, forKey: .dayOfYear) ?? defaults.dayOfYear
        dayCalendarYear = try container.decodeIfPresent(Int.self, forKey: .dayCalendarYear) ?? defaults.dayCalendarYear
        weeklyGoalMinutes = try container.decodeIfPresent(Int.self, forKey: .weeklyGoalMinutes) ?? 300
        weeklyFocusSeconds = try container.decodeIfPresent(Int.self, forKey: .weeklyFocusSeconds) ?? 0
        weekOfYear = try container.decodeIfPresent(Int.self, forKey: .weekOfYear) ?? defaults.weekOfYear
        calendarYear = try container.decodeIfPresent(Int.self, forKey: .calendarYear) ?? defaults.calendarYear
        gems = try container.decodeIfPresent(Int.self, forKey: .gems) ?? 0
        lifetimeBars = try container.decodeIfPresent(Int.self, forKey: .lifetimeBars) ?? forgedBars
        weeklyBars = try container.decodeIfPresent(Int.self, forKey: .weeklyBars) ?? 0
        sessionsToday = try container.decodeIfPresent(Int.self, forKey: .sessionsToday) ?? 0
        graceSeconds = try container.decodeIfPresent(Int.self, forKey: .graceSeconds) ?? 5
        isHardcoreEnabled = try container.decodeIfPresent(Bool.self, forKey: .isHardcoreEnabled) ?? false
        selectedAvatarID = try container.decodeIfPresent(String.self, forKey: .selectedAvatarID) ?? MedievalAvatar.default.id
        equippedAnvilSkinID = try container.decodeIfPresent(String.self, forKey: .equippedAnvilSkinID) ?? CosmeticCatalog.defaultAnvilID
        equippedFurnaceSkinID = try container.decodeIfPresent(String.self, forKey: .equippedFurnaceSkinID) ?? CosmeticCatalog.defaultFurnaceID
        equippedShopThemeID = try container.decodeIfPresent(String.self, forKey: .equippedShopThemeID) ?? CosmeticCatalog.defaultThemeID
        ownedCosmeticIDs = try container.decodeIfPresent([String].self, forKey: .ownedCosmeticIDs) ?? defaults.ownedCosmeticIDs
        weekdayFocusSeconds = Self.padded(try container.decodeIfPresent([Int].self, forKey: .weekdayFocusSeconds) ?? [], count: 7)
        hourlySessionCounts = Self.padded(try container.decodeIfPresent([Int].self, forKey: .hourlySessionCounts) ?? [], count: 24)
        if let completed = try container.decodeIfPresent(Bool.self, forKey: .onboardingCompleted) {
            onboardingCompleted = completed
        } else {
            onboardingCompleted = totalSessions > 0 || forgedBars > 0
        }
        trialStartedAt = try container.decodeIfPresent(Date.self, forKey: .trialStartedAt)
        hasUnlockedHardcore = try container.decodeIfPresent(Bool.self, forKey: .hasUnlockedHardcore) ?? false
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? false
    }

    private static func padded(_ values: [Int], count: Int) -> [Int] {
        if values.count == count { return values }
        var result = Array(repeating: 0, count: count)
        for (index, value) in values.prefix(count).enumerated() {
            result[index] = value
        }
        return result
    }
}
