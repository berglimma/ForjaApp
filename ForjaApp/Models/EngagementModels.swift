//
//  EngagementModels.swift
//  ForjaApp
//

import Foundation

enum DailyMissionKind: String, Codable, CaseIterable {
    case sessions
    case focusMinutes
    case longSession
    case dailyGoal
    case visitTrail
}

struct DailyMission: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let kind: DailyMissionKind
    let target: Int
    let rewardOre: Int

    func progress(in user: UserProgress) -> Int {
        switch kind {
        case .sessions:
            return user.dailyMissionProgress[id] ?? 0
        case .focusMinutes:
            return user.dailyMissionProgress[id] ?? 0
        case .longSession:
            return (user.dailyMissionProgress[id] ?? 0) >= 1 ? 1 : 0
        case .dailyGoal:
            return user.isDailyGoalMet ? 1 : 0
        case .visitTrail:
            return user.visitedTrailToday ? 1 : 0
        }
    }

    func isComplete(in user: UserProgress) -> Bool {
        progress(in: user) >= target
    }

    func isClaimed(in user: UserProgress) -> Bool {
        user.claimedMissionIDs.contains(id)
    }
}

enum DailyMissionCatalog {
    static let all: [DailyMission] = [
        DailyMission(
            id: "daily_session",
            title: "Primeira brasa",
            subtitle: "Complete 1 sessão de foco",
            icon: "flame.fill",
            kind: .sessions,
            target: 1,
            rewardOre: 1
        ),
        DailyMission(
            id: "daily_minutes",
            title: "Forja contínua",
            subtitle: "Acumule 30 min de foco hoje",
            icon: "hourglass",
            kind: .focusMinutes,
            target: 30,
            rewardOre: 2
        ),
        DailyMission(
            id: "daily_long",
            title: "Ofício sério",
            subtitle: "Complete uma sessão de 25+ min",
            icon: "hammer.fill",
            kind: .longSession,
            target: 1,
            rewardOre: 2
        ),
        DailyMission(
            id: "daily_goal",
            title: "Meta do dia",
            subtitle: "Atinga sua meta diária",
            icon: "target",
            kind: .dailyGoal,
            target: 1,
            rewardOre: 3
        ),
        DailyMission(
            id: "daily_trail",
            title: "Explorar a trilha",
            subtitle: "Visite a aba Trilha hoje",
            icon: "map.fill",
            kind: .visitTrail,
            target: 1,
            rewardOre: 1
        )
    ]

    static var activeToday: [DailyMission] {
        all
    }
}

struct SeasonalEvent: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let tagline: String
    let startMonth: Int
    let startDay: Int
    let endMonth: Int
    let endDay: Int
    let bonusOre: Int
    let minSessionMinutes: Int

    func isActive(on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        guard
            let start = calendar.date(from: DateComponents(year: year, month: startMonth, day: startDay)),
            let end = calendar.date(from: DateComponents(year: year, month: endMonth, day: endDay, hour: 23, minute: 59))
        else { return false }
        return date >= start && date <= end
    }
}

enum SeasonalEventCatalog {
    static let events: [SeasonalEvent] = [
        SeasonalEvent(
            id: "halloween",
            name: "Noite das Brumas",
            emoji: "🎃",
            tagline: "Sessões de 25+ min rendem +1 minério bônus",
            startMonth: 10, startDay: 15,
            endMonth: 11, endDay: 2,
            bonusOre: 1, minSessionMinutes: 25
        ),
        SeasonalEvent(
            id: "natal",
            name: "Forja do Inverno",
            emoji: "❄️",
            tagline: "Sessões de 25+ min rendem +1 minério bônus",
            startMonth: 12, startDay: 10,
            endMonth: 12, endDay: 31,
            bonusOre: 1, minSessionMinutes: 25
        ),
        SeasonalEvent(
            id: "verao",
            name: "Sol da Bigorna",
            emoji: "☀️",
            tagline: "Sessões de 25+ min rendem +1 minério bônus",
            startMonth: 1, startDay: 15,
            endMonth: 2, endDay: 28,
            bonusOre: 1, minSessionMinutes: 25
        )
    ]

    static func active(on date: Date = Date()) -> SeasonalEvent? {
        events.first { $0.isActive(on: date) }
    }
}

struct ForgeResultExtras: Equatable {
    var defeatedBoss: OreChallenge?
    var newlyClaimedMissions: [DailyMission]
    var missionBonusOre: Int
    var seasonalBonusOre: Int
    var dailyGoalJustMet: Bool
    var streakAfter: Int
    var streakFreezeUsed: Bool

    static let empty = ForgeResultExtras(
        defeatedBoss: nil,
        newlyClaimedMissions: [],
        missionBonusOre: 0,
        seasonalBonusOre: 0,
        dailyGoalJustMet: false,
        streakAfter: 0,
        streakFreezeUsed: false
    )
}

enum EngagementEngine {
    static func resetMissionsIfNeeded(_ progress: inout UserProgress, now: Date = Date()) {
        let day = UserProgress.dayOfYear(from: now)
        let year = UserProgress.dayCalendarYear(from: now)
        if day != progress.missionDayOfYear || year != progress.missionDayCalendarYear {
            progress.dailyMissionProgress = [:]
            progress.claimedMissionIDs = []
            progress.visitedTrailToday = false
            progress.missionDayOfYear = day
            progress.missionDayCalendarYear = year
        }
    }

    static func replenishStreakFreezeIfNeeded(_ progress: inout UserProgress, now: Date = Date()) {
        let week = UserProgress.weekOfYear(from: now)
        let year = UserProgress.calendarYear(from: now)
        if week != progress.streakFreezeWeek || year != progress.streakFreezeCalendarYear {
            progress.streakFreezesAvailable = min(1, progress.streakFreezesAvailable + 1)
            progress.streakFreezeWeek = week
            progress.streakFreezeCalendarYear = year
        }
    }

    static func newlyDefeatedBoss(before: Int, after: Int) -> OreChallenge? {
        guard after > before else { return nil }
        return OreChallengeLadder.milestones
            .filter { $0.oreGate > before && $0.oreGate <= after }
            .last
    }

    static func recordSuccessfulForge(
        _ progress: inout UserProgress,
        focusSeconds: Int,
        lifetimeBarsBefore: Int
    ) -> ForgeResultExtras {
        resetMissionsIfNeeded(&progress)
        progress.dailyMissionProgress["daily_session", default: 0] += 1
        progress.dailyMissionProgress["daily_minutes", default: 0] += focusSeconds / 60
        if focusSeconds >= 25 * 60 {
            progress.dailyMissionProgress["daily_long"] = 1
        }

        let wasDailyGoalMet = progress.isDailyGoalMet
        let lifetimeAfter = progress.lifetimeBars
        let boss = newlyDefeatedBoss(before: lifetimeBarsBefore, after: lifetimeAfter)
        if let boss, !progress.defeatedBossRanks.contains(boss.rank) {
            progress.defeatedBossRanks.append(boss.rank)
        }

        var bonusOre = 0
        var claimed: [DailyMission] = []
        for mission in DailyMissionCatalog.activeToday where mission.isComplete(in: progress) && !mission.isClaimed(in: progress) {
            progress.claimedMissionIDs.append(mission.id)
            bonusOre += mission.rewardOre
            claimed.append(mission)
        }
        if bonusOre > 0 {
            progress.forgedBars += bonusOre
        }

        var seasonalBonus = 0
        if let event = SeasonalEventCatalog.active(), focusSeconds >= event.minSessionMinutes * 60 {
            seasonalBonus = event.bonusOre
            progress.forgedBars += seasonalBonus
        }

        let dailyGoalJustMet = !wasDailyGoalMet && progress.isDailyGoalMet

        return ForgeResultExtras(
            defeatedBoss: boss,
            newlyClaimedMissions: claimed,
            missionBonusOre: bonusOre,
            seasonalBonusOre: seasonalBonus,
            dailyGoalJustMet: dailyGoalJustMet,
            streakAfter: progress.currentStreak,
            streakFreezeUsed: false
        )
    }

    static func missionsSummary(in progress: UserProgress) -> (completed: Int, total: Int) {
        let missions = DailyMissionCatalog.activeToday
        let completed = missions.filter { $0.isComplete(in: progress) }.count
        return (completed, missions.count)
    }

    static func markTrailVisited(_ progress: inout UserProgress) {
        resetMissionsIfNeeded(&progress)
        progress.visitedTrailToday = true
    }

    static func isAppTrialActive(trialStartedAt: Date?, now: Date = Date()) -> Bool {
        guard let start = trialStartedAt else { return false }
        let days = Calendar.current.dateComponents([.day], from: start, to: now).day ?? 0
        return days < EntitlementLimits.trialDurationDays
    }

    static func trialDaysRemaining(trialStartedAt: Date?, now: Date = Date()) -> Int {
        guard let start = trialStartedAt else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: start, to: now).day ?? 0
        return max(0, EntitlementLimits.trialDurationDays - days)
    }
}
