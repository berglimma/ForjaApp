//
//  OreForgeView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct OreForgeView: View {
    let progress: Double
    let isForging: Bool
    let isFailed: Bool
    let isSuccess: Bool

    @State private var shimmer = false

    private var oreColor: [Color] {
        if isFailed {
            return [Color(hex: "#4A5568") ?? .gray, Color(hex: "#718096") ?? .gray]
        }
        if isSuccess || progress >= 1 {
            return [Color(hex: "#CBD5E0") ?? .gray, Color(hex: "#F7FAFC") ?? .white, Color(hex: "#A0AEC0") ?? .gray]
        }

        let heat = progress
        return [
            Color(
                red: 0.35 + heat * 0.25,
                green: 0.28 + heat * 0.15,
                blue: 0.22
            ),
            Color(
                red: 0.55 + heat * 0.3,
                green: 0.35 + heat * 0.2,
                blue: 0.2
            ),
            Color(
                red: 0.75 + heat * 0.2,
                green: 0.45 + heat * 0.25,
                blue: 0.15 + heat * 0.1
            )
        ]
    }

    private var displayEmoji: String {
        if isSuccess || progress >= 1 { return "🧱" }
        if isFailed { return "🪨" }
        if progress > 0.7 { return "🔶" }
        if progress > 0.35 { return "🟫" }
        return "🪨"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(colors: oreColor, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 90, height: 70)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(shimmer ? 0.45 : 0.15), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: glowColor, radius: isForging ? 20 : 5)
                .scaleEffect(isForging ? 1 + progress * 0.08 : 1)
                .rotation3DEffect(
                    .degrees(isForging ? sin(progress * .pi * 4) * 3 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .animation(.spring(response: 0.5), value: progress)
                .animation(.easeOut(duration: 0.5), value: isFailed)

            Text(displayEmoji)
                .font(.system(size: 36))
                .scaleEffect(isSuccess ? 1.2 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSuccess)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }

    private var glowColor: Color {
        if isFailed { return .clear }
        if isSuccess { return Color(hex: "#F6E05E")?.opacity(0.6) ?? .yellow.opacity(0.6) }
        return Color(hex: "#ED8936")?.opacity(0.3 + progress * 0.4) ?? .orange.opacity(0.3)
    }
}

#Preview {
    OreForgeView(progress: 0.5, isForging: true, isFailed: false, isSuccess: false)
        .padding()
        .background(Color.black)
}
