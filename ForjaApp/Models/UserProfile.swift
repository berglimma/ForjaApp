//
//  UserProfile.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Foundation

struct AuthUserProfile: Equatable {
    let uid: String
    let email: String?
    let displayName: String
    let isAnonymous: Bool
    let provider: AuthProvider

    enum AuthProvider: String, Equatable {
        case anonymous
        case email
        case google
        case apple
    }
}

struct LeaderboardEntry: Identifiable, Equatable {
    let id: String
    let displayName: String
    let totalFocusSeconds: Int
    let successfulSessions: Int
    let rank: Int

    var formattedFocusTime: String {
        UserProgress.formatDuration(seconds: totalFocusSeconds)
    }
}

struct FocusChartSegment: Identifiable, Equatable {
    let id: String
    let title: String
    let seconds: Int
    let colorHex: String

    var minutesLabel: String {
        UserProgress.formatDuration(seconds: seconds)
    }
}
