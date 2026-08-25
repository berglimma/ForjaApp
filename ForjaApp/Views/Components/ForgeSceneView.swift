//
//  ForgeSceneView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI

struct ForgeSceneView: View {
    let progress: Double
    let isForging: Bool
    let isFailed: Bool
    let isSuccess: Bool
    var anvilSkinID: String = CosmeticCatalog.defaultAnvilID
    var furnaceSkinID: String = CosmeticCatalog.defaultFurnaceID

    private var isIdleSetup: Bool {
        !isForging && !isFailed && !isSuccess
    }

    var body: some View {
        ZStack {
            if isSuccess {
                SuccessGlowView()
                    .transition(.scale.combined(with: .opacity))
            }

            if isIdleSetup {
                AnvilView(isForging: false, isFailed: false, isProminent: true, skinID: anvilSkinID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 8) {
                    ZStack {
                        if isFailed {
                            SmokeView()
                                .offset(y: 10)
                        }

                        OreForgeView(
                            progress: progress,
                            isForging: isForging,
                            isFailed: isFailed,
                            isSuccess: isSuccess
                        )
                    }
                    .frame(height: 88)

                    ZStack {
                        if isForging && !isFailed {
                            SparkParticlesView()
                                .offset(y: 8)
                        }

                        ForgeFireView(intensity: fireIntensity, isActive: isForging && !isFailed, skinID: furnaceSkinID)
                    }
                    .frame(height: 110)

                    AnvilView(isForging: isForging, isFailed: isFailed, skinID: anvilSkinID)
                        .frame(height: 88)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var fireIntensity: Double {
        if isFailed { return 0 }
        if isSuccess { return 1.2 }
        return isForging ? 0.6 + progress * 0.6 : 0.15
    }
}

struct HammerStrikeView: View {
    var body: some View {
        PhaseAnimator([false, true]) { striking in
            ZStack(alignment: .top) {
                if !striking {
                    swingTrail
                }

                MedievalHammerShape()
                    .frame(width: 40, height: 76)
                    .rotationEffect(
                        .degrees(striking ? -65 : 34),
                        anchor: UnitPoint(x: 0.5, y: 0.96)
                    )
                    .offset(x: striking ? 36 : 38, y: striking ? -28 : -62)

                if striking {
                    impactSparks
                        .offset(x: -28, y: -4)
                }
            }
            .frame(width: 150, height: 110, alignment: .top)
        } animation: { striking in
            striking
                ? .easeIn(duration: 0.55)
                : .easeOut(duration: 0.9)
        }
    }

    private var swingTrail: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#ED8936")?.opacity(0.55 - Double(index) * 0.14) ?? .orange.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(42 - index * 8), height: 7)
                    .rotationEffect(.degrees(28 - Double(index) * 14))
                    .offset(x: CGFloat(28 + index * 16), y: CGFloat(-14 - index * 12))
            }
        }
        .allowsHitTesting(false)
    }

    private var impactSparks: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FBD38D")?.opacity(0.8) ?? .yellow.opacity(0.65),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 18
                    )
                )
                .frame(width: 34, height: 16)

            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FFFAF0") ?? .white,
                                Color(hex: "#F6E05E") ?? .yellow,
                                Color(hex: "#DD6B20") ?? .orange
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 2.5, height: CGFloat([9, 13, 11, 16, 10, 14, 8][index]))
                    .offset(
                        x: CGFloat([-16, -10, -4, 2, 8, 14, 20][index]),
                        y: CGFloat([-8, -16, -11, -20, -10, -17, -7][index])
                    )
                    .rotationEffect(.degrees([-38, -22, -8, 4, 16, 30, 46][index]))
            }
        }
        .allowsHitTesting(false)
    }
}

struct MedievalHammerShape: View {
    var body: some View {
        VStack(spacing: 0) {
            head
            leatherWrap
            haft
            pommel
        }
    }

    private var head: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#E2E8F0") ?? .white,
                        Color(hex: "#718096") ?? .gray,
                        Color(hex: "#2D3748") ?? .gray,
                        Color(hex: "#1A202C") ?? .black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color(hex: "#4A5568") ?? .gray
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.2
                    )
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(Color.white.opacity(0.32))
                    .frame(width: 18, height: 3)
                    .padding(.top, 3)
            }
            .frame(width: 30, height: 20)
            .shadow(color: .black.opacity(0.45), radius: 2, y: 1)
    }

    private var leatherWrap: some View {
        VStack(spacing: 3) {
            ForEach(0..<2, id: \.self) { _ in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#6B3A2A") ?? .brown,
                                Color(hex: "#3E1F16") ?? .brown
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12, height: 4)
            }
        }
        .padding(.top, 1)
    }

    private var haft: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#C4A35A") ?? .yellow,
                        Color(hex: "#8B5A2B") ?? .brown,
                        Color(hex: "#5C3317") ?? .brown
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(Color(hex: "#3E2723")?.opacity(0.55) ?? .black.opacity(0.4), lineWidth: 1)
            }
            .frame(width: 8, height: 38)
    }

    private var pommel: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#A0AEC0") ?? .gray,
                        Color(hex: "#4A5568") ?? .gray,
                        Color(hex: "#1A202C") ?? .black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 13, height: 7)
            .overlay {
                Capsule().strokeBorder(Color.white.opacity(0.25), lineWidth: 0.6)
            }
            .padding(.top, 1)
    }
}

struct SuccessGlowView: View {
    @State private var expand = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "#F6E05E")?.opacity(0.5) ?? .yellow.opacity(0.5), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: expand ? 120 : 60
                )
            )
            .frame(width: 220, height: 220)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    expand = true
                }
            }
    }
}

#Preview("Inicial") {
    ForgeSceneView(progress: 0, isForging: false, isFailed: false, isSuccess: false)
        .frame(height: 220)
        .background(Color(hex: "#0D1117") ?? .black)
}

#Preview("Forjando") {
    ForgeSceneView(progress: 0.6, isForging: true, isFailed: false, isSuccess: false)
        .frame(height: 280)
        .background(Color(hex: "#0D1117") ?? .black)
}
