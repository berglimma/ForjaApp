//
//  SocialModels.swift
//  ForjaApp
//

import Foundation

struct Guild: Identifiable, Equatable {
    let id: String
    var name: String
    var joinCode: String
    var ownerID: String
    var memberIDs: [String]
    var weeklyBars: [String: Int]
    var displayNames: [String: String]

    var rankedMembers: [GuildMemberScore] {
        memberIDs
            .map { uid in
                GuildMemberScore(
                    id: uid,
                    displayName: displayNames[uid] ?? "Ferreiro",
                    weeklyBars: weeklyBars[uid] ?? 0
                )
            }
            .sorted { $0.weeklyBars > $1.weeklyBars }
            .enumerated()
            .map { index, member in
                var ranked = member
                ranked.rank = index + 1
                return ranked
            }
    }
}

struct GuildMemberScore: Identifiable, Equatable {
    let id: String
    let displayName: String
    let weeklyBars: Int
    var rank: Int = 0
}

struct FocusChallenge: Identifiable, Equatable {
    enum Status: String, Equatable {
        case waiting
        case active
        case finished
    }

    let id: String
    var joinCode: String
    var hostID: String
    var hostName: String
    var opponentID: String?
    var opponentName: String?
    var hostFocusSeconds: Int
    var opponentFocusSeconds: Int
    var weekOfYear: Int
    var calendarYear: Int
    var status: Status

    func focusSeconds(for uid: String) -> Int {
        if uid == hostID { return hostFocusSeconds }
        if uid == opponentID { return opponentFocusSeconds }
        return 0
    }
}

struct SocialAlert: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}
