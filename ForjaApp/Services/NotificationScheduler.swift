//
//  NotificationScheduler.swift
//  ForjaApp
//

import Foundation
import UserNotifications

enum NotificationScheduler {
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
        center.removePendingNotificationRequests(withIdentifiers: [
            "forja.cooling",
            "forja.peak"
        ])

        guard progress.notificationsEnabled else { return }

        scheduleCoolingFurnace()
        schedulePeakReminder(hour: progress.peakHour)
    }

    private static func scheduleCoolingFurnace() {
        let content = UNMutableNotificationContent()
        content.title = "Sua fornalha está esfriando"
        content.body = "O minério esfria sem você. Volte à forja e recupere o foco."
        content.sound = .default

        var date = DateComponents()
        date.hour = 20
        date.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "forja.cooling", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private static func schedulePeakReminder(hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Hora de acender a forja"
        content.body = "Esse costuma ser seu horário de pico. Uma sessão agora rende mais barras."
        content.sound = .default

        var date = DateComponents()
        date.hour = hour
        date.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "forja.peak", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
