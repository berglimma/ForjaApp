//
//  DailyMissionsCard.swift
//  ForjaApp
//

import SwiftUI

struct DailyMissionsCard: View {
    @EnvironmentObject private var inventory: InventoryManager

    private var missions: [DailyMission] {
        DailyMissionCatalog.activeToday
    }

    private var summary: (completed: Int, total: Int) {
        EngagementEngine.missionsSummary(in: inventory.progress)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Missões do dia", systemImage: "scroll.fill")
                    .font(.headline)
                Spacer()
                Text("\(summary.completed)/\(summary.total)")
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }

            ForEach(missions) { mission in
                missionRow(mission)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func missionRow(_ mission: DailyMission) -> some View {
        let progress = mission.progress(in: inventory.progress)
        let complete = mission.isComplete(in: inventory.progress)
        let claimed = mission.isClaimed(in: inventory.progress)

        return HStack(spacing: 10) {
            Image(systemName: complete ? "checkmark.circle.fill" : mission.icon)
                .foregroundStyle(complete ? Color(hex: "#68D391") ?? .green : Color(hex: "#F6AD55") ?? .orange)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(mission.title)
                    .font(.subheadline.bold())
                Text(mission.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if mission.kind == .focusMinutes {
                    ProgressView(value: Double(min(progress, mission.target)), total: Double(mission.target))
                        .tint(Color(hex: "#F6AD55") ?? .orange)
                }
            }

            Spacer(minLength: 4)

            if claimed {
                Text("✓")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            } else {
                Text("+\(mission.rewardOre)🪨")
                    .font(.caption2.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }
        }
        .opacity(claimed ? 0.65 : 1)
    }
}
