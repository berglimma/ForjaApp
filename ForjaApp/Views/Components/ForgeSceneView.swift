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
    @State private var striking = false

    var body: some View {
        Text("🔨")
            .font(.system(size: 42))
            .rotationEffect(.degrees(striking ? -35 : 15))
            .offset(y: striking ? 6 : -10)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                    striking = true
                }
            }
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
