//
//  MedievalBackdropView.swift
//  ForjaApp
//

import SwiftUI

struct MedievalBackdropView: View {
    var torchlit: Bool = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#140E0A") ?? .black,
                    Color(hex: "#2A1C12") ?? .brown,
                    Color(hex: "#1A120C") ?? .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color(hex: "#3E2723")?.opacity(0.35) ?? .brown.opacity(0.3),
                    .clear,
                    Color(hex: "#1A237E")?.opacity(0.08) ?? .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Path { path in
                    let step: CGFloat = 28
                    var x: CGFloat = 0
                    while x < geo.size.width + step {
                        var y: CGFloat = 0
                        while y < geo.size.height + step {
                            path.addRect(CGRect(x: x, y: y, width: step - 2, height: step - 2))
                            y += step
                        }
                        x += step
                    }
                }
                .stroke(Color.black.opacity(0.18), lineWidth: 1)
            }

            if torchlit {
                RadialGradient(
                    colors: [
                        Color(hex: "#ED8936")?.opacity(0.18) ?? .orange.opacity(0.15),
                        .clear
                    ],
                    center: .topLeading,
                    startRadius: 8,
                    endRadius: 220
                )
                RadialGradient(
                    colors: [
                        Color(hex: "#C05621")?.opacity(0.12) ?? .orange.opacity(0.1),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 10,
                    endRadius: 260
                )
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.45),
                    .clear,
                    .clear,
                    Color.black.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        MedievalBackdropView()
        Text("Reino")
            .foregroundStyle(.white)
    }
}
