//
//  SeasonalEventBanner.swift
//  ForjaApp
//

import SwiftUI

struct SeasonalEventBanner: View {
    let event: SeasonalEvent

    var body: some View {
        HStack(spacing: 12) {
            Text(event.emoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.name)
                    .font(.subheadline.bold())
                Text(event.tagline)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "sparkles")
                .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#2D3748")?.opacity(0.9) ?? .gray,
                    Color(hex: "#1A202C")?.opacity(0.9) ?? .black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(hex: "#F6AD55")?.opacity(0.35) ?? .orange.opacity(0.35), lineWidth: 1)
        }
    }
}
