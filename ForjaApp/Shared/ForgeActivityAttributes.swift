//
//  ForgeActivityAttributes.swift
//  ForjaApp
//

import Foundation
import ActivityKit

struct ForgeActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var totalSeconds: Int
        var displayName: String
        var avatarImageName: String

        var progress: Double {
            guard totalSeconds > 0 else { return 0 }
            return 1 - (Double(remainingSeconds) / Double(totalSeconds))
        }

        var formattedRemaining: String {
            String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        }
    }

    var sessionTitle: String
}
