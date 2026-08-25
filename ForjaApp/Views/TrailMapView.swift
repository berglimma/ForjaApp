//
//  TrailMapView.swift
//  ForjaApp
//

import SwiftUI

struct TrailMapView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @State private var showAvatarPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    heroCard

                    WeeklyTrailMapView(
                        weekdaySeconds: inventory.progress.weekdayFocusSeconds,
                        avatar: inventory.progress.selectedAvatar,
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
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedID: inventory.progress.selectedAvatarID) { avatar in
                    inventory.selectAvatar(avatar)
                    showAvatarPicker = false
                }
            }
        }
    }

    private var heroCard: some View {
        HStack(spacing: 14) {
            Button { showAvatarPicker = true } label: {
                MedievalAvatarFaceView(avatar: inventory.progress.selectedAvatar, size: 64, lineWidth: 2)
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
                    Text("🪨 \(inventory.ore) minério")
                        .font(.subheadline.bold())
                    Text("💎 \(inventory.gems) gemas")
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

    var body: some View {
        NavigationStack {
            ScrollView {
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
                .padding()
            }
            .scrollIndicators(.visible)
            .navigationTitle("Avatar medieval")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
    }
}
