//
//  TimerSetupView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI

struct TimerSetupView: View {
    @Binding var selectedMinutes: Int
    @Binding var selectedSeconds: Int
    let estimatedBars: Int
    let lifetimeBars: Int
    let matchesPreset: (ForgeDurationOption) -> Bool
    let onSelectPreset: (ForgeDurationOption) -> Void
    let isDisabled: Bool

    private let presetColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var challenge: OreChallenge {
        OreChallengeLadder.active(lifetimeBars: lifetimeBars)
    }

    var body: some View {
        VStack(spacing: 14) {
            challengeBanner

            VStack(spacing: 6) {
                Text("Tempo de foco")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))

                Text(formattedDuration)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: formattedDuration)

                Text("Recompensa: \(rewardCaption)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }

            LazyVGrid(columns: presetColumns, spacing: 10) {
                ForEach(ForgeDurationOption.presets) { option in
                    Button {
                        onSelectPreset(option)
                    } label: {
                        VStack(spacing: 4) {
                            Text(option.label)
                                .font(.subheadline.bold())
                                .monospacedDigit()
                            Text(presetRewardLabel(for: option))
                                .font(.caption2)
                                .opacity(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    matchesPreset(option)
                                        ? Color(hex: "#C05621")?.opacity(0.85) ?? .orange.opacity(0.85)
                                        : Color.white.opacity(0.08)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(
                                            matchesPreset(option)
                                                ? Color(hex: "#F6AD55") ?? .orange
                                                : Color.white.opacity(0.12),
                                            lineWidth: matchesPreset(option) ? 2 : 1
                                        )
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isDisabled)
                }
            }

            HStack(spacing: 0) {
                durationPicker(
                    title: "Min",
                    selection: $selectedMinutes,
                    range: 0...120
                )

                Text(":")
                    .font(.title3.bold())
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 4)

                durationPicker(
                    title: "Seg",
                    selection: $selectedSeconds,
                    range: 0...59
                )
            }
            .frame(height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .disabled(isDisabled)
        }
    }

    private var challengeBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(challenge.creatureEmoji) \(challenge.name)")
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                Spacer()
                Text("\(OreChallengeLadder.formatOre(lifetimeBars)) / \(OreChallengeLadder.formatOre(challenge.oreGate))")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
            }
            ProgressView(
                value: Double(min(lifetimeBars, challenge.oreGate)),
                total: Double(max(challenge.oreGate, 1))
            )
            .tint(Color(hex: "#C4A574") ?? .yellow)
            Text("Abaixo de 15 min: +1, sem desafio. 15:00 +2 · 25:00 +3 · 45:00 +3 · 60:00 +4 · acima de 60 +5. \(challenge.name) conta a partir de \(challenge.minFocusMinutes) min.")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(10)
        .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var rewardCaption: String {
        if countsTowardChallenge {
            return "+\(estimatedBars) 🧱"
        }
        return "+\(estimatedBars) 🧱 · não soma no desafio"
    }

    private func presetRewardLabel(for option: ForgeDurationOption) -> String {
        let label = "+\(option.rewardBars) 🧱"
        if option.totalSeconds < challenge.minFocusMinutes * 60 {
            return "\(label) · —"
        }
        return label
    }

    private var countsTowardChallenge: Bool {
        selectedMinutes * 60 + selectedSeconds >= challenge.minFocusMinutes * 60
    }

    private var formattedDuration: String {
        String(format: "%02d:%02d", selectedMinutes, selectedSeconds)
    }

    private func durationPicker(title: String, selection: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))

            Picker(title, selection: selection) {
                ForEach(Array(range), id: \.self) { value in
                    Text(String(format: "%02d", value))
                        .monospacedDigit()
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TimerSetupView(
        selectedMinutes: .constant(25),
        selectedSeconds: .constant(30),
        estimatedBars: 2,
        lifetimeBars: 0,
        matchesPreset: { _ in false },
        onSelectPreset: { _ in },
        isDisabled: false
    )
    .padding()
    .background(Color.black)
}
