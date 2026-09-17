//
//  TrailMapView.swift
//  ForjaApp
//

import SwiftUI

struct TrailMapView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @State private var showAvatarPicker = false
    @State private var showWeeklyReport = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    heroCard
                    bossCard
                    weeklyReportButton

                    WeeklyTrailMapView(
                        weekdaySeconds: inventory.progress.weekdayFocusSeconds,
                        avatar: inventory.progress.selectedAvatar,
                        look: inventory.progress.customAvatarLook,
                        usesCustomLook: inventory.progress.usesCustomAvatar,
                        todayIndex: UserProgress.mondayFirstWeekdayIndex(from: Date()),
                        peakIndex: inventory.progress.peakWeekdayIndex,
                        totalSessions: inventory.progress.totalSessions,
                        successfulSessions: inventory.progress.successfulSessions,
                        currentStreak: inventory.progress.currentStreak,
                        weekOfYear: inventory.progress.weekOfYear,
                        weeklyFocusSeconds: inventory.progress.weeklyFocusSeconds
                    )

                    weekdayList
                    NavigationLink {
                        InventoryView()
                    } label: {
                        inventoryPreview
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .background {
                MedievalBackdropView()
            }
            .navigationTitle("Trilha")
            .onAppear { inventory.markTrailVisited() }
            .sheet(isPresented: $showWeeklyReport) {
                WeeklyReportView()
                    .environmentObject(inventory)
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedID: inventory.progress.selectedAvatarID) { avatar in
                    inventory.selectAvatar(avatar)
                    showAvatarPicker = false
                }
                .environmentObject(inventory)
            }
        }
    }

    private var heroCard: some View {
        HStack(spacing: 14) {
            Button { showAvatarPicker = true } label: {
                MedievalAvatarFaceView(
                    avatar: inventory.progress.selectedAvatar,
                    size: 64,
                    lineWidth: 2,
                    look: inventory.progress.customAvatarLook,
                    usesCustomLook: inventory.progress.usesCustomAvatar
                )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(inventory.progress.selectedAvatar.name)
                    .font(.title3.bold())
                Text(inventory.progress.selectedAvatar.title)
                    .font(.caption)
                    .foregroundStyle(Color(hex: inventory.progress.selectedAvatar.accentHex) ?? .orange)
                Text("Sequência \(inventory.progress.currentStreak) · \(inventory.progress.lifetimeBars) barras forjadas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var bossCard: some View {
        let active = OreChallengeLadder.active(lifetimeBars: inventory.progress.lifetimeBars)
        let defeated = inventory.progress.defeatedBossRanks.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Chefe da trilha")
                    .font(.headline)
                Spacer()
                Text("\(defeated)/\(OreChallengeLadder.maxRank)")
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }

            HStack(spacing: 14) {
                Text(active.creatureEmoji)
                    .font(.system(size: 44))
                VStack(alignment: .leading, spacing: 4) {
                    Text(active.name)
                        .font(.subheadline.bold())
                    Text(active.creature)
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                    Text(active.lore)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }

            ProgressView(
                value: Double(inventory.progress.lifetimeBars),
                total: Double(active.oreGate)
            )
            .tint(Color(hex: "#F6AD55") ?? .orange)

            Text("\(OreChallengeLadder.formatOre(inventory.progress.lifetimeBars)) de \(OreChallengeLadder.formatOre(active.oreGate)) barras")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var weeklyReportButton: some View {
        Button {
            showWeeklyReport = true
        } label: {
            HStack {
                Label("Resumo semanal", systemImage: "chart.bar.doc.horizontal")
                    .font(.subheadline.bold())
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var weekdayList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tempo de foco por dia")
                .font(.headline)
            ForEach(0..<7, id: \.self) { index in
                let seconds = inventory.progress.weekdayFocusSeconds[index]
                let isPeak = index == inventory.progress.peakWeekdayIndex && seconds > 0
                HStack {
                    Text(UserProgress.weekdayFullLabel(index: index))
                        .font(.subheadline)
                    Spacer()
                    Text(UserProgress.formatDuration(seconds: seconds))
                        .font(.subheadline.bold())
                        .foregroundStyle(isPeak ? (Color(hex: "#F6E05E") ?? .yellow) : .primary)
                }
                ProgressView(value: Double(seconds), total: Double(max(inventory.progress.weekdayFocusSeconds.max() ?? 1, 1)))
                    .tint(isPeak ? (Color(hex: "#F6E05E") ?? .yellow) : (Color(hex: "#F6AD55") ?? .orange))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var inventoryPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Baú do ferreiro")
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("\(inventory.ore) minério")
                        .font(.subheadline.bold())
                    Text("\(inventory.gems) gemas")
                        .font(.subheadline.bold())
                }
                Spacer()
                Text("\(inventory.progress.ownedCollectibles.count) colecionáveis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct AvatarPickerSheet: View {
    let selectedID: String
    let onSelect: (MedievalAvatar) -> Void
    @EnvironmentObject private var inventory: InventoryManager
    @State private var showStudio = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        showStudio = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "tshirt.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Criar corpo e vestimentas")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Ateliê com pele, cabelo, trajes e capa.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(MedievalAvatar.catalog) { avatar in
                            Button { onSelect(avatar) } label: {
                                VStack(spacing: 8) {
                                    MedievalAvatarFaceView(avatar: avatar, size: 72)
                                    Text(avatar.name).font(.headline)
                                    Text(avatar.lore)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            Color(hex: avatar.accentHex) ?? .orange,
                                            lineWidth: selectedID == avatar.id ? 2 : 0
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .scrollIndicators(.visible)
            .navigationTitle("Avatar medieval")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showStudio) {
                AvatarStudioView(look: inventory.progress.usesCustomAvatar
                    ? inventory.progress.customAvatarLook
                    : AvatarLook.seeded(from: MedievalAvatar.avatar(for: selectedID))
                )
                .environmentObject(inventory)
            }
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
    }
}
