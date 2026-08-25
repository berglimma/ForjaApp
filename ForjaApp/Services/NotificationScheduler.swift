//
//  NotificationScheduler.swift
//  ForjaApp
//

import Foundation
import UserNotifications

enum NotificationScheduler {
    private static var allIdentifiers: [String] {
        MedievalFocusCopy.NoticeSlot.allCases.map(\.identifier)
    }

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func reschedule(for progress: UserProgress) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: allIdentifiers)

        guard progress.notificationsEnabled else { return }

        let avatar = progress.selectedAvatar
        let salt = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let peak = progress.peakHour

        for slot in MedievalFocusCopy.NoticeSlot.allCases {
            let copy = MedievalFocusCopy.notification(slot: slot, avatar: avatar, salt: salt)
            var minute = slot.minute
            let hour = slot.hour(peakHour: peak)
            if slot == .peak {
                let occupiedHours = Set(
                    MedievalFocusCopy.NoticeSlot.allCases
                        .filter { $0 != .peak }
                        .map { $0.hour(peakHour: peak) }
                )
                if occupiedHours.contains(hour) {
                    minute = 8
                }
            }
            schedule(
                identifier: slot.identifier,
                title: copy.title,
                body: copy.body,
                hour: hour,
                minute: minute
            )
        }
    }

    private static func schedule(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.threadIdentifier = "forja.foco"
        content.categoryIdentifier = "FORJA_FOCUS"

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
