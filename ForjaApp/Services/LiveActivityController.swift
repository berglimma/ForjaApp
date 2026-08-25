//
//  LiveActivityController.swift
//  ForjaApp
//

import Foundation
import ActivityKit

@MainActor
final class LiveActivityController {
    static let shared = LiveActivityController()

    private var activity: Activity<ForgeActivityAttributes>?

    private init() {}

    func start(totalSeconds: Int, displayName: String, avatarImageName: String, sessionTitle: String = "Forja em andamento") {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        end()

        let attributes = ForgeActivityAttributes(sessionTitle: sessionTitle)
        let state = ForgeActivityAttributes.ContentState(
            remainingSeconds: totalSeconds,
            totalSeconds: totalSeconds,
            displayName: displayName,
            avatarImageName: avatarImageName
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }

    func update(remainingSeconds: Int, totalSeconds: Int, displayName: String, avatarImageName: String) {
        guard let activity else { return }
        let state = ForgeActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            totalSeconds: totalSeconds,
            displayName: displayName,
            avatarImageName: avatarImageName
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        guard let activity else { return }
        self.activity = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
