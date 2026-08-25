//
//  StreakWidget.swift
//  ForjaWidgets
//

import SwiftUI
import WidgetKit

struct StreakEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), snapshot: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: Date(), snapshot: WidgetBridge.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: Date(), snapshot: WidgetBridge.load())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct StreakWidgetView: View {
    let entry: StreakEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(entry.snapshot.avatarImageName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                Spacer()
                Label("\(entry.snapshot.currentStreak)", systemImage: "flame.fill")
                    .font(.headline.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }

            Text(entry.snapshot.displayName)
                .font(.caption.bold())
                .lineLimit(1)

            ProgressView(value: entry.snapshot.dailyProgress)
                .tint(Color(hex: "#F6AD55") ?? .orange)

            Text(entry.snapshot.isDailyGoalMet ? "Meta diária forjada" : entry.snapshot.remainingGoalLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if family == .systemMedium {
                Text("Recorde: \(entry.snapshot.bestStreak) · \(entry.snapshot.lifetimeBars) barras")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            Color(hex: "#0D1117") ?? .black
        }
    }
}

struct StreakWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ForjaStreakWidget", provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Sequência da Forja")
        .description("Streak e meta diária na tela inicial.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
