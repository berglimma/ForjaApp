//
//  SparkParticlesView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct SparkParticlesView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "#FBD38D") ?? .yellow)
                    .frame(width: sparkSize(for: index), height: sparkSize(for: index))
                    .offset(
                        x: animate ? sparkX(for: index, active: true) : sparkX(for: index, active: false),
                        y: animate ? sparkY(for: index, active: true) : sparkY(for: index, active: false)
                    )
                    .opacity(animate ? 0 : 0.9)
            }
        }
        .frame(width: 200, height: 120)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }

    private func sparkSize(for index: Int) -> CGFloat {
        CGFloat(3 + (index % 3))
    }

    private func sparkX(for index: Int, active: Bool) -> CGFloat {
        let base = CGFloat((index * 17) % 80 - 40)
        return active ? base * 1.6 : base * 0.2
    }

    private func sparkY(for index: Int, active: Bool) -> CGFloat {
        let base = CGFloat(-10 - (index * 9) % 50)
        return active ? base - 50 : base
    }
}

struct SmokeView: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: CGFloat(30 + i * 12), height: CGFloat(30 + i * 12))
                    .blur(radius: 10)
                    .offset(
                        x: drift ? CGFloat(i * 8 - 12) : CGFloat(i * 4 - 8),
                        y: drift ? CGFloat(-40 - i * 20) : CGFloat(-20 - i * 12)
                    )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2)) {
                drift = true
            }
        }
    }
}
