//
//  WeeklyTrailMapView.swift
//  ForjaApp
//

import SwiftUI

enum TrailBiome: Equatable {
    case tenebrous
    case hauntedWood
    case emberGlade
    case greenWood
    case autumn
    case riverside
    case moonlit
    case castleRoad

    var ground: [Color] {
        switch self {
        case .tenebrous:
            return [Color(hex: "#1A1016") ?? .black, Color(hex: "#2D1B24") ?? .gray]
        case .hauntedWood:
            return [Color(hex: "#1C1420") ?? .black, Color(hex: "#32243A") ?? .purple]
        case .emberGlade:
            return [Color(hex: "#3D2B12") ?? .brown, Color(hex: "#744210") ?? .brown]
        case .greenWood:
            return [Color(hex: "#22543D") ?? .green, Color(hex: "#276749") ?? .green]
        case .autumn:
            return [Color(hex: "#7B341E") ?? .orange, Color(hex: "#C05621") ?? .orange]
        case .riverside:
            return [Color(hex: "#2A4365") ?? .blue, Color(hex: "#2F855A") ?? .green]
        case .moonlit:
            return [Color(hex: "#1A365D") ?? .blue, Color(hex: "#2C5282") ?? .blue]
        case .castleRoad:
            return [Color(hex: "#4A5568") ?? .gray, Color(hex: "#D69E2E") ?? .yellow]
        }
    }

    var path: Color {
        switch self {
        case .tenebrous, .hauntedWood: return Color(hex: "#1A202C") ?? .black
        case .emberGlade: return Color(hex: "#C05621") ?? .orange
        case .greenWood: return Color(hex: "#D69E2E") ?? .yellow
        case .autumn: return Color(hex: "#F6AD55") ?? .orange
        case .riverside: return Color(hex: "#90CDF4") ?? .cyan
        case .moonlit: return Color(hex: "#9F7AEA") ?? .purple
        case .castleRoad: return Color(hex: "#F6E05E") ?? .yellow
        }
    }

    var treeEmoji: String {
        switch self {
        case .tenebrous, .hauntedWood: return "🌲"
        case .emberGlade: return "🌳"
        case .greenWood: return "🌲"
        case .autumn: return "🍂"
        case .riverside: return "🌿"
        case .moonlit: return "🌙"
        case .castleRoad: return "🏰"
        }
    }

    var isDark: Bool {
        self == .tenebrous || self == .hauntedWood
    }
}

struct WeeklyTrailMapView: View {
    let weekdaySeconds: [Int]
    let avatar: MedievalAvatar
    let todayIndex: Int
    let peakIndex: Int
    var totalSessions: Int = 0
    var successfulSessions: Int = 0
    var currentStreak: Int = 0
    var weekOfYear: Int = 1
    var weeklyFocusSeconds: Int = 0

    @State private var walkAlong: CGFloat = 0
    @State private var bobbing = false
    @State private var fogDrift = false
    @State private var torchPulse = false
    @State private var flagWave = false
    @State private var crowOffset: CGFloat = 0

    private var daysUsed: Int {
        weekdaySeconds.filter { $0 > 0 }.count
    }

    private var hasNeverForged: Bool {
        totalSessions == 0 && weeklyFocusSeconds == 0 && daysUsed == 0
    }

    private var isFrequent: Bool {
        daysUsed >= 4 || currentStreak >= 3 || successfulSessions >= 8 || weeklyFocusSeconds >= 90 * 60
    }

    private var maxSeconds: Int {
        max(weekdaySeconds.max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Trilha da semana")
                    .font(.headline)
                Spacer()
                Text(statusCaption)
                    .font(.caption.bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                    .lineLimit(1)
            }

            GeometryReader { geo in
                let size = geo.size
                let points = trailPoints(in: size)
                let avatarPoint = pointOnTrail(walkAlong, points: points)

                ZStack {
                    mapSky(in: size)

                    ZStack {
                        terrainLayer(size: size, points: points)
                        pathLayer(points: points)
                        decorations(size: size, points: points)
                        ForEach(0..<7, id: \.self) { index in
                            dayMarker(index: index, at: points[index])
                        }
                        castle(at: points[6], size: size)
                        walkingHero(at: avatarPoint, points: points)
                        if hasNeverForged || daysUsed < 3 {
                            mistOverlay(in: size)
                        }
                    }
                    .rotation3DEffect(
                        .degrees(18),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .center,
                        perspective: 0.48
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .frame(height: 360)

            Text(loreCaption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear { startAnimations() }
        .onChange(of: todayIndex) { _, _ in
            withAnimation(.easeInOut(duration: 2.4)) {
                walkAlong = CGFloat(todayIndex)
            }
        }
    }

    private var statusCaption: String {
        if hasNeverForged { return "Floresta adormecida" }
        if isFrequent { return "Reinos alternando" }
        return "Pico: \(UserProgress.weekdayFullLabel(index: peakIndex))"
    }

    private var loreCaption: String {
        if hasNeverForged {
            return "\(avatar.name) atravessa bosques tenebrosos. Acenda a forja para abrir o caminho até o castelo."
        }
        if isFrequent {
            return "O reino reconhece o ofício: clareiras, rio e estrada real se revezam a cada semana. \(avatar.name) marcha rumo ao castelo."
        }
        return "Cada dia forjado ilumina a trilha. Dias vazios permanecem na névoa da floresta negra."
    }

    private func biome(for index: Int) -> TrailBiome {
        let seconds = weekdaySeconds.indices.contains(index) ? weekdaySeconds[index] : 0
        if seconds <= 0 {
            return index.isMultiple(of: 2) ? .tenebrous : .hauntedWood
        }
        if isFrequent {
            let cycle: [TrailBiome] = [.emberGlade, .greenWood, .riverside, .autumn, .moonlit, .greenWood, .castleRoad]
            return cycle[(index + weekOfYear) % cycle.count]
        }
        return index == 6 ? .castleRoad : .emberGlade
    }

    private func startAnimations() {
        walkAlong = 0
        withAnimation(.easeInOut(duration: 3.4)) {
            walkAlong = CGFloat(todayIndex)
        }
        withAnimation(.easeInOut(duration: 0.38).repeatForever(autoreverses: true)) {
            bobbing = true
        }
        withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true)) {
            fogDrift = true
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            torchPulse = true
        }
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
            flagWave = true
        }
        withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
            crowOffset = 1
        }
    }

    private func mapSky(in size: CGSize) -> some View {
        let colors: [Color]
        if hasNeverForged {
            colors = [
                Color(hex: "#0B0610") ?? .black,
                Color(hex: "#2A0F18") ?? .red.opacity(0.4),
                Color(hex: "#1A1020") ?? .black
            ]
        } else if isFrequent {
            colors = [
                Color(hex: "#1A365D") ?? .blue,
                Color(hex: "#9F7AEA")?.opacity(0.55) ?? .purple,
                Color(hex: "#F6AD55")?.opacity(0.35) ?? .orange
            ]
        } else {
            colors = [
                Color(hex: "#1A202C") ?? .gray,
                Color(hex: "#2D2416") ?? .brown,
                Color(hex: "#22543D")?.opacity(0.5) ?? .green
            ]
        }

        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            .overlay {
                if hasNeverForged {
                    RadialGradient(
                        colors: [Color(hex: "#742A2A")?.opacity(0.35) ?? .red.opacity(0.3), .clear],
                        center: .top,
                        startRadius: 10,
                        endRadius: 160
                    )
                }
            }
    }

    private func terrainLayer(size: CGSize, points: [CGPoint]) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                let biome = biome(for: index)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: biome.ground + [.clear],
                            center: .center,
                            startRadius: 4,
                            endRadius: 70
                        )
                    )
                    .frame(width: 118, height: 62)
                    .opacity(0.92)
                    .position(points[index])
                    .offset(y: 10)
            }
        }
    }

    private func pathLayer(points: [CGPoint]) -> some View {
        ZStack {
            TrailPathShape(points: points)
                .stroke(
                    Color.black.opacity(0.45),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
                )
                .offset(y: 6)

            ForEach(0..<6, id: \.self) { index in
                let a = points[index]
                let b = points[index + 1]
                Path { path in
                    path.move(to: a)
                    path.addQuadCurve(to: b, control: controlPoint(from: a, to: b))
                }
                .stroke(
                    biome(for: index).path,
                    style: StrokeStyle(lineWidth: 11, lineCap: .round, lineJoin: .round)
                )
                .opacity(weekdaySeconds[index] > 0 || weekdaySeconds[index + 1] > 0 ? 1 : 0.28)
                .shadow(color: biome(for: index).path.opacity(0.5), radius: weekdaySeconds[index] > 0 ? 6 : 0)
            }

            TrailPathShape(points: points)
                .stroke(
                    Color.white.opacity(0.18),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 8])
                )
                .offset(y: -3)
        }
    }

    private func decorations(size: CGSize, points: [CGPoint]) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                let point = points[index]
                let biome = biome(for: index)
                Group {
                    treeCluster(biome: biome, lit: weekdaySeconds[index] > 0)
                        .position(x: point.x - 36, y: point.y - 28)
                    treeCluster(biome: biome, lit: weekdaySeconds[index] > 0)
                        .scaleEffect(0.78)
                        .position(x: point.x + 40, y: point.y - 18)

                    if biome.isDark {
                        Text("🦇")
                            .font(.caption)
                            .offset(x: fogDrift ? 10 : -8, y: fogDrift ? -6 : 4)
                            .position(point)
                            .opacity(0.7)
                    } else if weekdaySeconds[index] > 0 {
                        Circle()
                            .fill(Color(hex: "#F6E05E")?.opacity(torchPulse ? 0.55 : 0.2) ?? .yellow.opacity(0.3))
                            .frame(width: 18, height: 18)
                            .blur(radius: 6)
                            .position(x: point.x + 22, y: point.y - 16)
                        Text("🔥")
                            .font(.caption2)
                            .position(x: point.x + 22, y: point.y - 10)
                    }
                }
            }

            if hasNeverForged {
                Text("🦅")
                    .font(.title3)
                    .offset(x: crowOffset * (size.width - 40) - 20, y: 28 + (fogDrift ? 8 : 0))
                    .opacity(0.8)
            }
        }
    }

    private func treeCluster(biome: TrailBiome, lit: Bool) -> some View {
        VStack(spacing: -6) {
            if biome.isDark {
                Triangle()
                    .fill(Color(hex: "#1A202C") ?? .black)
                    .frame(width: 22, height: 28)
                    .overlay {
                        Triangle()
                            .fill(Color(hex: "#2D1B24") ?? .gray)
                            .frame(width: 14, height: 18)
                            .offset(y: 4)
                    }
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "#171923") ?? .black)
                    .frame(width: 5, height: 8)
            } else {
                Text(biome.treeEmoji)
                    .font(.title2)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    .saturation(lit ? 1 : 0.4)
            }
        }
        .opacity(lit || biome.isDark ? 1 : 0.55)
    }

    private func dayMarker(index: Int, at point: CGPoint) -> some View {
        let seconds = weekdaySeconds[index]
        let used = seconds > 0
        let isToday = index == todayIndex
        let isPeak = index == peakIndex && used

        return VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(used ? (isPeak ? Color(hex: "#F6E05E") ?? .yellow : Color(hex: "#ED8936") ?? .orange) : Color(hex: "#2D3748") ?? .gray)
                    .frame(width: isToday ? 24 : 16, height: isToday ? 24 : 16)
                    .shadow(color: used ? .orange.opacity(0.6) : .black.opacity(0.8), radius: used ? 6 : 2)
                if isToday {
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        .frame(width: 28, height: 28)
                }
            }

            Text(UserProgress.weekdayLabel(index: index))
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .shadow(radius: 2)
            Text("\(seconds / 60)m")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(used ? (Color(hex: "#F6E05E") ?? .yellow) : .white.opacity(0.45))
        }
        .position(point)
        .offset(y: 26)
    }

    private func castle(at point: CGPoint, size: CGSize) -> some View {
        let awakened = weekdaySeconds[6] > 0 || isFrequent
        return VStack(spacing: 0) {
            Text("🚩")
                .font(.caption)
                .rotationEffect(.degrees(flagWave ? 12 : -8), anchor: .bottom)
                .offset(x: 10, y: 4)
            HStack(alignment: .bottom, spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(awakened ? Color(hex: "#A0AEC0") ?? .gray : Color(hex: "#1A202C") ?? .black)
                    .frame(width: 10, height: 22)
                RoundedRectangle(cornerRadius: 2)
                    .fill(awakened ? Color(hex: "#E2E8F0") ?? .white : Color(hex: "#2D3748") ?? .gray)
                    .frame(width: 18, height: 32)
                RoundedRectangle(cornerRadius: 2)
                    .fill(awakened ? Color(hex: "#A0AEC0") ?? .gray : Color(hex: "#1A202C") ?? .black)
                    .frame(width: 10, height: 22)
            }
            .overlay(alignment: .top) {
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { _ in
                        Rectangle()
                            .fill(awakened ? Color(hex: "#CBD5E0") ?? .gray : Color(hex: "#4A5568") ?? .gray)
                            .frame(width: 4, height: 5)
                    }
                }
                .offset(y: -4)
            }
            Text(awakened ? "🏰" : "🌫️")
                .font(.caption)
                .offset(y: -6)
        }
        .shadow(color: awakened ? (Color(hex: "#F6E05E")?.opacity(0.4) ?? .yellow.opacity(0.3)) : .black, radius: 8)
        .position(x: point.x + 8, y: point.y - 48)
        .opacity(0.95)
    }

    private func walkingHero(at point: CGPoint, points: [CGPoint]) -> some View {
        let nextIndex = min(Int(walkAlong) + 1, points.count - 1)
        let facingLeft = points[nextIndex].x < point.x
        return VStack(spacing: 0) {
            Text(avatar.emoji)
                .font(.system(size: 36))
                .scaleEffect(x: facingLeft ? -1 : 1, y: 1)
                .offset(y: bobbing ? -7 : 1)
                .shadow(color: .black.opacity(0.55), radius: 4, y: 3)
            Capsule()
                .fill(.black.opacity(0.35))
                .frame(width: 18, height: 5)
                .offset(y: 2)
                .scaleEffect(x: bobbing ? 0.8 : 1.1)
        }
        .position(point)
        .offset(y: -36)
        .animation(.easeInOut(duration: 0.35), value: bobbing)
    }

    private func mistOverlay(in size: CGSize) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(hasNeverForged ? 0.42 : 0.22))
                .frame(width: 180, height: 50)
                .blur(radius: 18)
                .offset(x: fogDrift ? 30 : -24, y: 40)
            Ellipse()
                .fill(Color(hex: "#2D1B24")?.opacity(0.35) ?? .gray.opacity(0.3))
                .frame(width: 220, height: 40)
                .blur(radius: 16)
                .offset(x: fogDrift ? -20 : 28, y: 110)
        }
        .allowsHitTesting(false)
    }

    private func trailPoints(in size: CGSize) -> [CGPoint] {
        let xs: [CGFloat] = [0.10, 0.24, 0.38, 0.52, 0.66, 0.80, 0.90]
        let ys: [CGFloat] = [0.78, 0.52, 0.70, 0.38, 0.60, 0.32, 0.48]
        return zip(xs, ys).map { x, y in
            CGPoint(x: x * size.width, y: y * size.height)
        }
    }

    private func pointOnTrail(_ progress: CGFloat, points: [CGPoint]) -> CGPoint {
        guard points.count > 1 else { return .zero }
        let maxIndex = CGFloat(points.count - 1)
        let clamped = min(max(progress, 0), maxIndex)
        let index = Int(clamped)
        let t = clamped - CGFloat(index)
        let a = points[index]
        let b = points[min(index + 1, points.count - 1)]
        let control = controlPoint(from: a, to: b)
        let u = 1 - t
        return CGPoint(
            x: u * u * a.x + 2 * u * t * control.x + t * t * b.x,
            y: u * u * a.y + 2 * u * t * control.y + t * t * b.y
        )
    }

    private func controlPoint(from a: CGPoint, to b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: min(a.y, b.y) - 18)
    }
}

private struct TrailPathShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let control = CGPoint(
                x: (previous.x + current.x) / 2,
                y: min(previous.y, current.y) - 18
            )
            path.addQuadCurve(to: current, control: control)
        }
        return path
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview("Nunca usou") {
    WeeklyTrailMapView(
        weekdaySeconds: Array(repeating: 0, count: 7),
        avatar: .default,
        todayIndex: 1,
        peakIndex: 0,
        totalSessions: 0
    )
    .padding()
    .background(Color.black)
}

#Preview("Frequente") {
    WeeklyTrailMapView(
        weekdaySeconds: [1200, 2400, 800, 3600, 1800, 900, 2100],
        avatar: MedievalAvatar.catalog[2],
        todayIndex: 3,
        peakIndex: 3,
        totalSessions: 20,
        successfulSessions: 16,
        currentStreak: 5,
        weekOfYear: 12,
        weeklyFocusSeconds: 12800
    )
    .padding()
    .background(Color.black)
}
