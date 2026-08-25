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

                Text("Recompensa: +\(estimatedBars) 🧱")
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
                            Text("+\(reward(for: option)) 🧱")
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
                    .disabled(isDisabled || option.minutes < challenge.minFocusMinutes)
                    .opacity(option.minutes < challenge.minFocusMinutes ? 0.4 : 1)
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
                Text("\(lifetimeBars)/100.000")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
            }
            ProgressView(
                value: Double(min(lifetimeBars, OreChallengeLadder.cap)),
                total: Double(OreChallengeLadder.cap)
            )
            .tint(Color(hex: "#C4A574") ?? .yellow)
            Text("Mínimo \(challenge.minFocusMinutes) min · recomendado \(challenge.recommendedMinutes) min · graça \(challenge.graceCap)s")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(10)
        .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func reward(for option: ForgeDurationOption) -> Int {
        OreChallengeLadder.adjustedReward(
            base: option.rewardBars,
            durationSeconds: option.totalSeconds,
            lifetimeBars: lifetimeBars
        )
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
