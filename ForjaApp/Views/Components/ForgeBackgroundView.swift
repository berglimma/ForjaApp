//
//  ForgeBackgroundView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ForgeBackgroundView: View {
    let isActive: Bool
    let isFailed: Bool

    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#0D1117") ?? .black,
                    Color(hex: "#1A202C") ?? .gray,
                    isFailed
                        ? (Color(hex: "#2D1B1B") ?? .red.opacity(0.3))
                        : (Color(hex: "#2D2416") ?? .brown.opacity(0.3))
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: isFailed)

            if isActive && !isFailed {
                RadialGradient(
                    colors: [
                        Color(hex: "#ED8936")?.opacity(pulse ? 0.25 : 0.12) ?? .orange.opacity(0.15),
                        .clear
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: pulse ? 280 : 220
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
            }
        }
    }
}
