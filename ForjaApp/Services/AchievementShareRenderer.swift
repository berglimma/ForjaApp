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

    @MainActor
    static func renderProfileCard(
        displayName: String,
        avatarEmoji: String,
        photo: UIImage?,
        lifetimeBars: Int,
        currentStreak: Int,
        focusSeconds: Int,
        challengeName: String
    ) -> UIImage? {
        let card = ProfileShareCard(
            displayName: displayName,
            avatarEmoji: avatarEmoji,
            photo: photo,
            lifetimeBars: lifetimeBars,
            currentStreak: currentStreak,
            focusText: UserProgress.formatDuration(seconds: focusSeconds),
            challengeName: challengeName
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

struct ProfileShareCard: View {
    let displayName: String
    let avatarEmoji: String
    let photo: UIImage?
    let lifetimeBars: Int
    let currentStreak: Int
    let focusText: String
    let challengeName: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#140E0A") ?? .black,
                    Color(hex: "#5C3A1E") ?? .brown,
                    Color(hex: "#1A1208") ?? .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 32) {
                Text("FORJA")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                    .tracking(10)

                Text("Pergaminho do Ferreiro")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.88))

                portrait
                    .frame(width: 280, height: 280)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "#F6AD55") ?? .orange, lineWidth: 8))
                    .shadow(color: .orange.opacity(0.4), radius: 24)

                Text(displayName)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(challengeName)
                    .font(.title3.bold())
                    .foregroundStyle(Color(hex: "#C4A574") ?? .yellow)

                VStack(spacing: 14) {
                    Text("\(lifetimeBars) minérios no ofício")
                    Text("Sequência \(currentStreak)")
                    Text(focusText)
                }
                .font(.title2.bold())
                .foregroundStyle(.white.opacity(0.82))

                Text("Pomodoro RPG · Estrada de areia e barro")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.top, 28)
            }
            .padding(56)
        }
        .frame(width: 1080, height: 1920)
    }

    @ViewBuilder
    private var portrait: some View {
        if let photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.white.opacity(0.08)
                Text(avatarEmoji)
                    .font(.system(size: 140))
            }
        }
    }
}

struct ProfileSocialPreview: View {
    let displayName: String
    let avatarEmoji: String
    let photo: UIImage?
    let lifetimeBars: Int
    let streak: Int
    let focusText: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#2A1C12") ?? .brown,
                    Color(hex: "#1A1208") ?? .black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 16) {
                Group {
                    if let photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Text(avatarEmoji)
                            .font(.system(size: 44))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white.opacity(0.08))
                    }
                }
                .frame(width: 88, height: 88)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(hex: "#F6AD55") ?? .orange, lineWidth: 2))

                VStack(alignment: .leading, spacing: 6) {
                    Text(displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(lifetimeBars) minérios · sequência \(streak)")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "#FBD38D") ?? .yellow)
                    Text(focusText)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(20)
        }
    }
}
