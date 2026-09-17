//
//  WeeklyReportView.swift
//  ForjaApp
//

import SwiftUI

struct WeeklyReportView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @Environment(\.dismiss) private var dismiss

    private var progress: UserProgress { inventory.progress }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    statsGrid
                    weekdayChart
                    bossProgress
                    missionsCard
                }
                .padding()
            }
            .background { MedievalBackdropView() }
            .navigationTitle("Resumo semanal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Text("Semana \(progress.weekOfYear)")
                .font(.title2.bold())
            Text(progress.isWeeklyGoalMet ? "Meta semanal forjada! 🔥" : "Faltam \(remainingWeeklyLabel) para a meta")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            ProgressView(value: progress.weeklyGoalProgress)
                .tint(Color(hex: "#F6AD55") ?? .orange)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statTile("Foco", UserProgress.formatDuration(seconds: progress.weeklyFocusSeconds), "clock.fill")
            statTile("Barras", "\(progress.weeklyBars)", "cube.fill")
            statTile("Sequência", "\(progress.currentStreak) dias", "flame.fill")
            statTile("Sessões", "\(progress.weeklySuccessfulSessions)", "hammer.fill")
        }
    }

    private var weekdayChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Foco por dia")
                .font(.headline)
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    let seconds = progress.weekdayFocusSeconds[safe: index] ?? 0
                    let maxSeconds = max(progress.weekdayFocusSeconds.max() ?? 1, 1)
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F6AD55") ?? .orange)
                            .frame(height: max(4, CGFloat(seconds) / CGFloat(maxSeconds) * 60))
                        Text(UserProgress.weekdayLabel(index: index))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var bossProgress: some View {
        let active = OreChallengeLadder.active(lifetimeBars: progress.lifetimeBars)
        let defeated = progress.defeatedBossRanks.count

        return VStack(alignment: .leading, spacing: 8) {
            Text("Trilha dos 100k")
                .font(.headline)
            HStack(spacing: 10) {
                Text(active.creatureEmoji)
                    .font(.largeTitle)
                VStack(alignment: .leading, spacing: 4) {
                    Text(active.name)
                        .font(.subheadline.bold())
                    Text("\(OreChallengeLadder.formatOre(progress.lifetimeBars)) / \(OreChallengeLadder.formatOre(active.oreGate)) barras")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text("\(defeated) chefes derrotados de \(OreChallengeLadder.maxRank)")
                .font(.caption)
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var missionsCard: some View {
        let summary = EngagementEngine.missionsSummary(in: progress)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Missões de hoje")
                .font(.headline)
            Text("\(summary.completed) de \(summary.total) concluídas")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var remainingWeeklyLabel: String {
        let remaining = max(0, progress.weeklyGoalSeconds - progress.weeklyFocusSeconds)
        return UserProgress.formatDuration(seconds: remaining)
    }

    private func statTile(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
