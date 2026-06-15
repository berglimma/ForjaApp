//
//  ForgeFireView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ForgeFireView: View {
    let intensity: Double
    let isActive: Bool

    @State private var flicker = false
    @State private var wave = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                FlameShape(waveOffset: wave ? CGFloat(index) * 4 : 0)
                    .fill(
                        LinearGradient(
                            colors: flameColors(for: index),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: flameWidth(for: index), height: flameHeight(for: index))
                    .opacity(flameOpacity(for: index))
                    .blur(radius: index == 0 ? 2 : 0)
                    .offset(x: CGFloat(index - 1) * 18, y: flicker ? -4 : 2)
                    .scaleEffect(x: flicker ? 1.05 : 0.95, y: flicker ? 1.08 : 0.92)
            }

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FBD38D")?.opacity(0.6 * intensity) ?? .orange.opacity(0.4),
                            Color(hex: "#C05621")?.opacity(0.3 * intensity) ?? .red.opacity(0.2),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 40)
                .offset(y: 30)
                .blur(radius: 8)
        }
        .opacity(isActive ? 1 : max(0.2, intensity * 0.3))
        .animation(.easeOut(duration: 0.6), value: intensity)
        .onAppear {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
                flicker = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                wave = true
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                flicker = false
                wave = false
                withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
                    flicker = true
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    wave = true
                }
            }
        }
    }

    private func flameColors(for index: Int) -> [Color] {
        switch index {
        case 0:
            return [Color(hex: "#C05621") ?? .red, Color(hex: "#ED8936") ?? .orange, Color(hex: "#FBD38D") ?? .yellow]
        case 1:
            return [Color(hex: "#9B2C2C") ?? .red, Color(hex: "#DD6B20") ?? .orange, Color(hex: "#F6AD55") ?? .orange]
        default:
            return [Color(hex: "#742A2A") ?? .red, Color(hex: "#C05621") ?? .orange, Color(hex: "#ED8936") ?? .yellow]
        }
    }

    private func flameWidth(for index: Int) -> CGFloat {
        CGFloat(50 + index * 8) * CGFloat(0.7 + intensity * 0.5)
    }

    private func flameHeight(for index: Int) -> CGFloat {
        CGFloat(90 + index * 15) * CGFloat(0.6 + intensity * 0.7)
    }

    private func flameOpacity(for index: Int) -> Double {
        (1.0 - Double(index) * 0.15) * min(1, intensity)
    }
}

struct FlameShape: Shape {
    var waveOffset: CGFloat

    var animatableData: CGFloat {
        get { waveOffset }
        set { waveOffset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h),
            control1: CGPoint(x: w * 0.85 + waveOffset, y: h * 0.35),
            control2: CGPoint(x: w * 0.95, y: h * 0.75)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h),
            control1: CGPoint(x: w * 0.55, y: h * 0.95),
            control2: CGPoint(x: w * 0.25, y: h * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * 0.05, y: h * 0.75),
            control2: CGPoint(x: w * 0.15 - waveOffset, y: h * 0.35)
        )
        return path
    }
}

#Preview {
    ForgeFireView(intensity: 1, isActive: true)
        .frame(height: 150)
        .background(Color.black)
}
