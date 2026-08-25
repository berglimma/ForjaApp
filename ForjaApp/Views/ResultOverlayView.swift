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
    var countsTowardChallenge: Bool = true
    let onDismiss: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 20) {
                resultEmblem
                    .scaleEffect(appear ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appear)

                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if case .success = state {
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Text("🪨")
                            Text("+\(barsEarned) Minério")
                                .font(.headline)
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
        }
    }

    @ViewBuilder
    private var resultEmblem: some View {
        switch state {
        case .failed(let reason):
            Text(reason.emoji)
                .font(.system(size: 64))
        default:
            MedievalAvatarFaceView(avatar: avatar, size: 88)
        }
    }

    private var isSuccess: Bool {
        if case .success = state { return true }
        return false
    }

    private var title: String {
        switch state {
        case .success:
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
            return countsTowardChallenge
                ? MedievalFocusCopy.successMessage(avatar: avatar, bars: barsEarned)
                : MedievalFocusCopy.practiceSuccessMessage(avatar: avatar, bars: barsEarned)
        case .failed(let reason):
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
