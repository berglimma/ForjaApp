//
//  AnvilView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI

struct AnvilView: View {
    let isForging: Bool
    let isFailed: Bool
    var isProminent: Bool = false
    var skinID: String = CosmeticCatalog.defaultAnvilID

    private var showForgeEffects: Bool {
        isForging && !isFailed
    }

    var body: some View {
        ZStack(alignment: .top) {
            Image("Anvil")
                .resizable()
                .renderingMode(.original)
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: isProminent ? 220 : 180, height: isProminent ? 96 : 72)
                .opacity(isFailed ? 0.45 : 1)
                .saturation(isFailed ? 0.2 : 1)
                .colorMultiply(anvilTint)
                .shadow(
                    color: showForgeEffects
                        ? (Color(hex: "#ED8936")?.opacity(0.35) ?? .orange.opacity(0.35))
                        : .clear,
                    radius: showForgeEffects ? 12 : 0,
                    y: showForgeEffects ? 4 : 0
                )
                .animation(.easeInOut(duration: 0.35), value: isProminent)

            if showForgeEffects {
                HammerStrikeView()
                    .offset(x: isProminent ? 70 : 58, y: -32)
            }
        }
        .background(Color.clear)
    }

    private var anvilTint: Color {
        switch skinID {
        case "anvil_obsidian", "pack_halloween":
            return Color(hex: "#9F7AEA") ?? .purple
        case "anvil_royal", "theme_royal":
            return Color(hex: "#F6E05E") ?? .yellow
        case "pack_natal":
            return Color(hex: "#90CDF4") ?? .cyan
        default:
            return .white
        }
    }
}
