//
//  ForgeSessionState.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Foundation

enum ForgeSessionState: Equatable {
    case idle
    case ready
    case forging
    case success
    case failed(reason: ForgeFailureReason)
}

enum ForgeFailureReason: Equatable {
    case leftApp
    case cancelled

    var title: String {
        switch self {
        case .leftApp: return "Fogo apagado!"
        case .cancelled: return "Forja cancelada"
        }
    }

    var message: String {
        switch self {
        case .leftApp:
            return "Você saiu do app e a forja estragou. O minério voltou ao estado bruto."
        case .cancelled:
            return "Você desistiu antes de concluir a forja."
        }
    }

    var emoji: String {
        switch self {
        case .leftApp: return "💨"
        case .cancelled: return "🛑"
        }
    }
}

struct ForgeDurationOption: Identifiable, Hashable {
    let minutes: Int
    let seconds: Int

    var id: String { "\(minutes)-\(seconds)" }

    var totalSeconds: Int { minutes * 60 + seconds }

    var label: String {
        String(format: "%02d:%02d", minutes, seconds)
    }

    var rewardBars: Int {
        Self.rewardBars(for: totalSeconds)
    }

    static let presets: [ForgeDurationOption] = [
        ForgeDurationOption(minutes: 5, seconds: 0),
        ForgeDurationOption(minutes: 15, seconds: 0),
        ForgeDurationOption(minutes: 25, seconds: 0),
        ForgeDurationOption(minutes: 45, seconds: 0),
        ForgeDurationOption(minutes: 60, seconds: 0),
        ForgeDurationOption(minutes: 90, seconds: 0)
    ]

    static func rewardBars(for totalSeconds: Int) -> Int {
        if totalSeconds < 15 * 60 { return 1 }
        if totalSeconds < 25 * 60 { return 2 }
        if totalSeconds < 60 * 60 { return 3 }
        if totalSeconds == 60 * 60 { return 4 }
        if totalSeconds < 90 * 60 { return 5 }
        return 6
    }
}
