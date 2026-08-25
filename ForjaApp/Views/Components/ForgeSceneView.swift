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
            ZStack {
                if striking {
                    strikeSparks
                }
                MedievalHammerShape()
                    .frame(width: 78, height: 92)
                    .rotationEffect(.degrees(striking ? 32 : -52), anchor: .bottom)
                    .offset(y: striking ? 8 : -16)
                    .shadow(
                        color: Color(hex: "#ED8936")?.opacity(striking ? 0.55 : 0.15) ?? .orange.opacity(0.3),
                        radius: striking ? 10 : 4,
                        y: 2
                    )
            }
        } animation: { striking in
            striking
                ? .easeIn(duration: 0.14)
                : .easeOut(duration: 0.32)
        }
    }

    private var strikeSparks: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(Color(hex: "#F6E05E") ?? .yellow)
                    .frame(width: 3, height: 10)
                    .offset(
                        x: CGFloat([-14, -6, 2, 10, 16][index]),
                        y: CGFloat([10, 16, 8, 14, 12][index])
                    )
                    .rotationEffect(.degrees([-28, -8, 6, 22, 38][index]))
                    .opacity(0.85)
            }
        }
        .offset(y: 18)
    }
}

struct MedievalHammerShape: View {
    var body: some View {
        ZStack {
            haft
            leatherWrap
            pommel
            head
        }
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
            .frame(width: 11, height: 64)
            .offset(y: 12)
    }

    private var leatherWrap: some View {
        VStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { _ in
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
                    .frame(width: 15, height: 5)
            }
        }
        .offset(y: 18)
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
            .frame(width: 16, height: 8)
            .overlay {
                Capsule().strokeBorder(Color.white.opacity(0.25), lineWidth: 0.6)
            }
            .offset(y: 42)
    }

    private var head: some View {
        ZStack {
            HammerHeadSilhouette()
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
                    HammerHeadSilhouette()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    Color(hex: "#4A5568") ?? .gray
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.2
                        )
                }
                .frame(width: 64, height: 28)
                .shadow(color: .black.opacity(0.45), radius: 2, y: 1)

            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: 18, height: 4)
                .offset(x: 14, y: -6)
        }
        .offset(y: -28)
    }
}

private struct HammerHeadSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.18, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.12))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.98, y: h * 0.5),
            control: CGPoint(x: w * 1.02, y: h * 0.18)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.78, y: h * 0.88),
            control: CGPoint(x: w * 1.02, y: h * 0.82)
        )
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.88))
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.38))
        path.closeSubpath()
        return path
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
