//
//  ResultOverlayView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ResultOverlayView: View {
    let state: ForgeSessionState
    let barsEarned: Int
    var avatar: MedievalAvatar = .default
    var look: AvatarLook? = nil
    var usesCustomLook: Bool = false
    var countsTowardChallenge: Bool = true
    var extras: ForgeResultExtras = .empty
    let onDismiss: () -> Void

    @State private var appear = false
    @State private var pulse = false
    @State private var sparkle = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture { }

            if isSuccess {
                successGlow
            }

            VStack(spacing: 20) {
                resultEmblem
                    .scaleEffect(appear ? 1 : 0.3)
                    .scaleEffect(pulse && isSuccess ? 1.06 : 1)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appear)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if case .success = state {
                    rewardSection
                    celebrationBadges
                }

                if case .failed = state, extras.streakFreezeUsed {
                    streakFreezeBadge
                }

                Button(action: onDismiss) {
                    Text(buttonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(ForgePrimaryButtonStyle())
                .padding(.top, 8)
            }
            .padding(28)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: "#1A202C") ?? .gray)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(
                                isSuccess ? Color(hex: "#F6E05E") ?? .yellow : Color.red.opacity(0.5),
                                lineWidth: 2
                            )
                    }
            }
            .padding(.horizontal, 32)
            .scaleEffect(appear ? 1 : 0.85)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                appear = true
            }
            if isSuccess {
                pulse = true
                sparkle = true
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            } else if extras.streakFreezeUsed {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }

    private var successGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color(hex: "#F6AD55")?.opacity(sparkle ? 0.35 : 0.15) ?? .orange.opacity(0.2),
                        .clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 180
                )
            )
            .frame(width: 360, height: 360)
            .blur(radius: 8)
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private var resultEmblem: some View {
        switch state {
        case .failed(let reason):
            Text(reason.emoji)
                .font(.system(size: 64))
        case .success:
            if let boss = extras.defeatedBoss {
                VStack(spacing: 6) {
                    Text(boss.creatureEmoji)
                        .font(.system(size: 56))
                    Text("CHEFE DERROTADO")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                }
            } else {
                MedievalAvatarFaceView(
                    avatar: avatar,
                    size: 88,
                    look: look,
                    usesCustomLook: usesCustomLook
                )
            }
        default:
            EmptyView()
        }
    }

    private var rewardSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text("🪨")
                Text("+\(barsEarned) Minério")
                    .font(.headline)
            }
            if extras.missionBonusOre > 0 {
                Text("+\(extras.missionBonusOre) de missões")
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#68D391") ?? .green)
            }
            if extras.seasonalBonusOre > 0 {
                Text("+\(extras.seasonalBonusOre) evento sazonal")
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
            }
            if !countsTowardChallenge {
                Text("Não soma no desafio da estrada")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(hex: "#C05621")?.opacity(0.35) ?? .orange.opacity(0.3), in: Capsule())
    }

    @ViewBuilder
    private var celebrationBadges: some View {
        VStack(spacing: 8) {
            if extras.dailyGoalJustMet {
                badgeRow(icon: "target", text: "Meta diária forjada!")
            }
            if extras.streakAfter > 1 {
                badgeRow(icon: "flame.fill", text: "Sequência de \(extras.streakAfter) dias")
            }
            if let boss = extras.defeatedBoss {
                Text(boss.name)
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                Text(boss.lore)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            ForEach(extras.newlyClaimedMissions) { mission in
                badgeRow(icon: "scroll.fill", text: "Missão: \(mission.title)")
            }
        }
    }

    private var streakFreezeBadge: some View {
        VStack(spacing: 6) {
            Label("Escudo de sequência usado", systemImage: "snowflake")
                .font(.subheadline.bold())
                .foregroundStyle(Color(hex: "#63B3ED") ?? .blue)
            Text("Sua sequência de \(extras.streakAfter) dias foi preservada.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: "#2B6CB0")?.opacity(0.25) ?? .blue.opacity(0.2), in: Capsule())
    }

    private func badgeRow(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.bold())
            .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
    }

    private var isSuccess: Bool {
        if case .success = state { return true }
        return false
    }

    private var title: String {
        switch state {
        case .success:
            if extras.defeatedBoss != nil {
                return "Vitória épica!"
            }
            return countsTowardChallenge
                ? MedievalFocusCopy.successTitle(avatar: avatar)
                : MedievalFocusCopy.practiceSuccessTitle(avatar: avatar)
        case .failed(let reason): return MedievalFocusCopy.failureTitle(reason: reason)
        default: return ""
        }
    }

    private var message: String {
        switch state {
        case .success:
            if let boss = extras.defeatedBoss {
                return "\(boss.creature) caiu diante da sua forja. \(boss.creatureEmoji)"
            }
            return countsTowardChallenge
                ? MedievalFocusCopy.successMessage(avatar: avatar, bars: barsEarned)
                : MedievalFocusCopy.practiceSuccessMessage(avatar: avatar, bars: barsEarned)
        case .failed(let reason):
            if extras.streakFreezeUsed {
                return "O fogo apagou, mas o escudo de sequência te protegeu."
            }
            return MedievalFocusCopy.failureMessage(avatar: avatar, reason: reason)
        default:
            return ""
        }
    }

    private var buttonTitle: String {
        isSuccess ? "Coletar minério" : "Tentar novamente"
    }
}

#Preview {
    ResultOverlayView(
        state: .success,
        barsEarned: 2,
        onDismiss: {}
    )
}
