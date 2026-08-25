//
//  AchievementShareRenderer.swift
//  ForjaApp
//

import SwiftUI
import UIKit

enum AchievementShareRenderer {
    @MainActor
    static func renderLegendaryCard(
        itemName: String,
        emoji: String,
        displayName: String,
        lifetimeBars: Int
    ) -> UIImage? {
        let card = LegendaryShareCard(
            itemName: itemName,
            emoji: emoji,
            displayName: displayName,
            lifetimeBars: lifetimeBars
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        renderer.proposedSize = ProposedViewSize(width: 1080, height: 1920)
        return renderer.uiImage
    }
}

struct LegendaryShareCard: View {
    let itemName: String
    let emoji: String
    let displayName: String
    let lifetimeBars: Int

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#1A1208") ?? .black,
                    Color(hex: "#C05621") ?? .orange,
                    Color(hex: "#1A202C") ?? .gray
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 28) {
                Text("FORJA")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                    .tracking(8)

                Text("Barra lendária forjada")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.9))

                Text(emoji)
                    .font(.system(size: 120))

                Text(itemName)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                VStack(spacing: 8) {
                    Text(displayName)
                        .font(.title3.bold())
                        .foregroundStyle(Color(hex: "#FBD38D") ?? .yellow)
                    Text("\(lifetimeBars) barras forjadas no ofício")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.top, 20)

                Text("Pomodoro RPG · Foco gamificado")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.top, 40)
            }
            .padding(48)
        }
        .frame(width: 1080, height: 1920)
    }
}
