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
        calendarYear: Self.currentCalendarYear()
    )

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

    mutating func rollDayIfNeeded(now: Date = Date()) {
        let day = Self.dayOfYear(from: now)
        let year = Self.dayCalendarYear(from: now)
        if day != dayOfYear || year != dayCalendarYear {
            dailyFocusSeconds = 0
            dayOfYear = day
            dayCalendarYear = year
        }
    }

    mutating func rollWeekIfNeeded(now: Date = Date()) {
        let week = Self.weekOfYear(from: now)
        let year = Self.calendarYear(from: now)
        if week != weekOfYear || year != calendarYear {
            weeklyFocusSeconds = 0
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
    }

    mutating func addUnfulfilledTime(seconds: Int) {
        guard seconds > 0 else { return }
        unfulfilledFocusSeconds += seconds
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

    private static func dayOfYear(from date: Date) -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    private static func dayCalendarYear(from date: Date) -> Int {
        Calendar.current.component(.year, from: date)
    }

    private static func weekOfYear(from date: Date) -> Int {
        Calendar.current.component(.weekOfYear, from: date)
    }

    private static func calendarYear(from date: Date) -> Int {
        Calendar.current.component(.yearForWeekOfYear, from: date)
    }
}
