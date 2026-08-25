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
        avatarImageName: String,
        photo: UIImage?,
        lifetimeBars: Int,
        successfulForges: Int,
        currentStreak: Int,
        focusSeconds: Int,
        challengeName: String,
        dayOfYear: Int = MedievalYearlyQuotes.dayOfYear()
    ) -> UIImage? {
        let card = ProfileShareCard(
            displayName: displayName,
            avatarImageName: avatarImageName,
            photo: photo,
            lifetimeBars: lifetimeBars,
            successfulForges: successfulForges,
            currentStreak: currentStreak,
            focusText: UserProgress.formatDuration(seconds: focusSeconds),
            challengeName: challengeName,
            dayOfYear: dayOfYear
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
    let avatarImageName: String
    let photo: UIImage?
    let lifetimeBars: Int
    let successfulForges: Int
    let currentStreak: Int
    let focusText: String
    let challengeName: String
    var dayOfYear: Int = MedievalYearlyQuotes.dayOfYear()

    var body: some View {
        ZStack {
            MedievalShareBackdrop()

            VStack(spacing: 0) {
                Text("FORJA")
                    .font(.system(size: 52, weight: .black, design: .serif))
                    .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                    .tracking(12)
                    .shadow(color: .black.opacity(0.7), radius: 8, y: 4)
                    .padding(.top, 72)

                Text(MedievalYearlyQuotes.battleCry(dayOfYear: dayOfYear))
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .italic()
                    .foregroundStyle(Color(hex: "#FBD38D") ?? .yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 72)
                    .padding(.top, 18)
                    .shadow(color: .black.opacity(0.8), radius: 4)

                portrait
                    .frame(width: 260, height: 260)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "#F6AD55") ?? .orange, lineWidth: 10))
                    .shadow(color: Color(hex: "#ED8936")?.opacity(0.55) ?? .orange.opacity(0.5), radius: 28)
                    .padding(.top, 36)

                Text(displayName)
                    .font(.system(size: 52, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.8), radius: 6)
                    .padding(.top, 22)

                Text(challengeName)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(hex: "#C4A574") ?? .yellow)
                    .padding(.top, 6)

                HStack(spacing: 18) {
                    statBlock(title: "Tempo de foco", value: focusText, emblem: "⏳")
                    statBlock(title: "Barras", value: "\(lifetimeBars)", emblem: "🧱")
                    statBlock(title: "Forjas", value: "\(successfulForges)", emblem: "⚒️")
                }
                .padding(.horizontal, 48)
                .padding(.top, 40)

                Text("Sequência \(currentStreak) dias de ofício")
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 20)

                Spacer()

                VStack(spacing: 16) {
                    Text("Crônica do dia \(dayOfYear)")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                        .tracking(2)

                    Text(MedievalYearlyQuotes.dailyPhrase(dayOfYear: dayOfYear))
                        .font(.system(size: 26, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(Color(hex: "#FFFAF0") ?? .white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .padding(36)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#2A1C12")?.opacity(0.78) ?? .black.opacity(0.7))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(Color(hex: "#C4A574")?.opacity(0.7) ?? .yellow.opacity(0.5), lineWidth: 2)
                        }
                )
                .padding(.horizontal, 56)
                .padding(.bottom, 64)
            }
        }
        .frame(width: 1080, height: 1920)
    }

    private func statBlock(title: String, value: String, emblem: String) -> some View {
        VStack(spacing: 10) {
            Text(emblem)
                .font(.system(size: 36))
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Color(hex: "#FBD38D") ?? .yellow)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color(hex: "#8B5A2B") ?? .brown, lineWidth: 2)
                }
        )
    }

    @ViewBuilder
    private var portrait: some View {
        if let photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
        } else {
            Image(avatarImageName)
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
        }
    }
}

struct MedievalShareBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#0B0610") ?? .black,
                    Color(hex: "#1A1208") ?? .black,
                    Color(hex: "#3E2723") ?? .brown,
                    Color(hex: "#140E0A") ?? .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Color(hex: "#1A365D")?.opacity(0.35) ?? .blue.opacity(0.3), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 520
            )

            ForEach(0..<18, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(index.isMultiple(of: 3) ? 0.35 : 0.16))
                    .frame(width: index.isMultiple(of: 4) ? 5 : 3)
                    .offset(
                        x: CGFloat([-460, -380, -290, -200, -90, 40, 140, 240, 330, 410, 470, -420, -150, 80, 300, -50, 190, -250][index]),
                        y: CGFloat([-820, -760, -800, -700, -840, -780, -720, -810, -750, -830, -690, -640, -600, -560, -620, -880, -660, -580][index])
                    )
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#FAF089") ?? .yellow, Color(hex: "#D69E2E")?.opacity(0.2) ?? .yellow.opacity(0.2)],
                        center: .center,
                        startRadius: 4,
                        endRadius: 70
                    )
                )
                .frame(width: 90, height: 90)
                .offset(x: 380, y: -780)

            castleSkyline
                .offset(y: -420)

            Image("Anvil")
                .resizable()
                .scaledToFit()
                .frame(width: 520)
                .opacity(0.28)
                .offset(y: 620)

            HStack {
                torch
                Spacer()
                torch
            }
            .padding(.horizontal, 48)
            .offset(y: 120)

            LinearGradient(
                colors: [.black.opacity(0.25), .clear, .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
    }

    private var castleSkyline: some View {
        HStack(alignment: .bottom, spacing: 10) {
            tower(height: 120)
            tower(height: 200)
            tower(height: 160)
            tower(height: 240)
            tower(height: 150)
            tower(height: 190)
        }
        .foregroundStyle(Color(hex: "#1A1208") ?? .black)
        .opacity(0.85)
        .overlay(alignment: .top) {
            Text("🏰")
                .font(.system(size: 64))
                .offset(y: -28)
        }
    }

    private func tower(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle().frame(width: 10, height: 14)
                }
            }
            Rectangle()
                .frame(width: 64, height: height)
        }
    }

    private var torch: some View {
        VStack(spacing: -6) {
            Circle()
                .fill(Color(hex: "#ED8936")?.opacity(0.55) ?? .orange.opacity(0.5))
                .frame(width: 70, height: 70)
                .blur(radius: 18)
            Text("🔥")
                .font(.system(size: 44))
            Rectangle()
                .fill(Color(hex: "#5C3317") ?? .brown)
                .frame(width: 10, height: 90)
        }
    }
}

struct ProfileSocialPreview: View {
    let displayName: String
    let avatarImageName: String
    let photo: UIImage?
    let lifetimeBars: Int
    let successfulForges: Int
    let streak: Int
    let focusText: String
    let challengeName: String
    var dayOfYear: Int = MedievalYearlyQuotes.dayOfYear()

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 1080
            ProfileShareCard(
                displayName: displayName,
                avatarImageName: avatarImageName,
                photo: photo,
                lifetimeBars: lifetimeBars,
                successfulForges: successfulForges,
                currentStreak: streak,
                focusText: focusText,
                challengeName: challengeName,
                dayOfYear: dayOfYear
            )
            .frame(width: 1080, height: 1920)
            .scaleEffect(scale, anchor: .top)
            .frame(width: geo.size.width, height: 1920 * scale, alignment: .top)
        }
        .aspectRatio(1080 / 1920, contentMode: .fit)
        .allowsHitTesting(false)
    }
}
