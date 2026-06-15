//
//  ResultOverlayView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ResultOverlayView: View {
    let state: ForgeSessionState
    let barsEarned: Int
    let onDismiss: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 20) {
                Text(emoji)
                    .font(.system(size: 64))
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
                    HStack(spacing: 8) {
                        Text("🧱")
                        Text("+\(barsEarned) Barra\(barsEarned == 1 ? "" : "s") Forjada\(barsEarned == 1 ? "" : "s")")
                            .font(.headline)
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

    private var isSuccess: Bool {
        if case .success = state { return true }
        return false
    }

    private var emoji: String {
        switch state {
        case .success: return "✨"
        case .failed(let reason): return reason.emoji
        default: return "🔥"
        }
    }

    private var title: String {
        switch state {
        case .success: return "Forja concluída!"
        case .failed(let reason): return reason.title
        default: return ""
        }
    }

    private var message: String {
        switch state {
        case .success:
            return "Você manteve o foco e transformou o minério em barras valiosas."
        case .failed(let reason):
            return reason.message
        default:
            return ""
        }
    }

    private var buttonTitle: String {
        isSuccess ? "Coletar barras" : "Tentar novamente"
    }
}

#Preview {
    ResultOverlayView(
        state: .success,
        barsEarned: 2,
        onDismiss: {}
    )
}
