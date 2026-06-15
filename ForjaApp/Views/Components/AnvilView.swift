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
}
