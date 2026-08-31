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
    case sandClay
    case darkSwamp

    var isDark: Bool {
        self == .tenebrous || self == .hauntedWood || self == .darkSwamp
    }

    var isSwamp: Bool {
        self == .darkSwamp
    }

    var creature: (image: String, name: String) {
        switch self {
        case .darkSwamp: return ("Creature_lodoento", "Lodoento")
        case .tenebrous: return ("Creature_umbrawolf", "Umbrawolf")
        case .hauntedWood: return ("Creature_corvo", "Corvo-de-Ferro")
        case .emberGlade: return ("Creature_cervo", "Cervo-Brasão")
        case .greenWood: return ("Creature_grifo", "Grifo-do-Charco")
        case .autumn: return ("Creature_basilisco", "Basilisco-Cinza")
        case .riverside: return ("Creature_hidra", "Hidra-do-Lodo")
        case .moonlit: return ("Creature_serpe", "Serpe-Musgo")
        case .castleRoad: return ("Creature_wyrm", "Wyrm-de-Brejo")
        case .sandClay: return ("Creature_drake", "Drake-Pântano")
        }
    }

    /// Uma criatura distinta por dia (segunda → domingo).
    static func creature(forWeekday index: Int) -> (image: String, name: String) {
        let week: [(String, String)] = [
            ("Creature_umbrawolf", "Umbrawolf"),
            ("Creature_corvo", "Corvo-de-Ferro"),
            ("Creature_cervo", "Cervo-Brasão"),
            ("Creature_lodoento", "Lodoento"),
            ("Creature_drake", "Drake-Pântano"),
            ("Creature_grifo", "Grifo-do-Charco"),
            ("Creature_wyrm", "Wyrm-de-Brejo")
        ]
        return week[max(0, min(6, index))]
    }
}

struct WeeklyTrailMapView: View {
    let weekdaySeconds: [Int]
    let avatar: MedievalAvatar
    var look: AvatarLook? = nil
    var usesCustomLook: Bool = false
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
    @State private var pan = CGSize.zero
    @GestureState private var drag = CGSize.zero
    @State private var hoveredCreature: String?

    private let mapScale: CGFloat = 1.85
    /// Quinta (3) → sexta (4) no índice segunda-primeiro.
    private let swampFromIndex = 3

    private var daysUsed: Int {
        weekdaySeconds.filter { $0 > 0 }.count
    }

    private var hasNeverForged: Bool {
        totalSessions == 0 && weeklyFocusSeconds == 0 && daysUsed == 0
    }

    private var isFrequent: Bool {
        daysUsed >= 4 || currentStreak >= 3 || successfulSessions >= 8 || weeklyFocusSeconds >= 90 * 60
    }

    private var skippedToday: Bool {
        weekdaySeconds.indices.contains(todayIndex) && weekdaySeconds[todayIndex] == 0
    }

    private var isSomber: Bool {
        hasNeverForged || skippedToday
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
                let viewport = geo.size
                let world = CGSize(width: viewport.width * mapScale, height: viewport.height * mapScale)
                let points = trailPoints(in: world)
                let avatarPoint = pointOnTrail(walkAlong, points: points)
                let livePan = CGSize(width: pan.width + drag.width, height: pan.height + drag.height)

                ZStack {
                    mapWorld(world: world, points: points, avatarPoint: avatarPoint)
                        .frame(width: world.width, height: world.height)
                        .offset(livePan)
                }
                .frame(width: viewport.width, height: viewport.height)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .highPriorityGesture(mapDrag(viewport: viewport, world: world))
                .onAppear {
                    center(on: points[min(todayIndex, 6)], viewport: viewport, world: world, animated: false)
                }
            }
            .frame(height: 400)

            Text(loreCaption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear { startAnimations() }
        .onChange(of: todayIndex) { _, newValue in
            withAnimation(.easeInOut(duration: 2.4)) {
                walkAlong = CGFloat(newValue)
            }
        }
    }

    private var statusCaption: String {
        if isSomber { return "Reino em sombra" }
        if isFrequent { return "Arraste · reinos abertos" }
        return "Arraste · pico \(UserProgress.weekdayFullLabel(index: peakIndex))"
    }

    private var loreCaption: String {
        if isSomber {
            return "A forja não acendeu hoje: o reino apaga. Passe o cursor nas criaturas para ver o nome. Entre quinta e sexta o pântano toma a estrada."
        }
        if isFrequent {
            return "A calçada se firma até o castelo. Passe o cursor nas criaturas. O pântano abre entre quinta e sexta."
        }
        return "Passe o cursor nas criaturas para ler o nome. Entre quinta e sexta a estrada afunda no pântano."
    }

    private func biome(for index: Int) -> TrailBiome {
        if index == swampFromIndex || index == swampFromIndex + 1 {
            return .darkSwamp
        }
        let seconds = weekdaySeconds.indices.contains(index) ? weekdaySeconds[index] : 0
        if seconds <= 0 {
            return index.isMultiple(of: 2) ? .tenebrous : .hauntedWood
        }
        if isFrequent {
            let cycle: [TrailBiome] = [.sandClay, .emberGlade, .greenWood, .riverside, .autumn, .moonlit, .castleRoad]
            return cycle[(index + weekOfYear) % cycle.count]
        }
        return index == 6 ? .castleRoad : .sandClay
    }

    private func dayWasSkipped(_ index: Int) -> Bool {
        guard weekdaySeconds.indices.contains(index) else { return true }
        if index < todayIndex { return weekdaySeconds[index] == 0 }
        if index == todayIndex { return skippedToday }
        return false
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
    }

    private func mapDrag(viewport: CGSize, world: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($drag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                pan = clampPan(
                    CGSize(width: pan.width + value.translation.width, height: pan.height + value.translation.height),
                    viewport: viewport,
                    world: world
                )
            }
    }

    private func center(on point: CGPoint, viewport: CGSize, world: CGSize, animated: Bool) {
        let next = clampPan(
            CGSize(
                width: world.width / 2 - point.x,
                height: world.height / 2 - point.y
            ),
            viewport: viewport,
            world: world
        )
        if animated {
            withAnimation(.easeInOut(duration: 0.45)) { pan = next }
        } else {
            pan = next
        }
    }

    private func clampPan(_ value: CGSize, viewport: CGSize, world: CGSize) -> CGSize {
        let maxX = max(0, (world.width - viewport.width) / 2)
        let maxY = max(0, (world.height - viewport.height) / 2)
        return CGSize(
            width: min(max(value.width, -maxX), maxX),
            height: min(max(value.height, -maxY), maxY)
        )
    }

    private func mapWorld(world: CGSize, points: [CGPoint], avatarPoint: CGPoint) -> some View {
        ZStack(alignment: .topLeading) {
            Image("TrailMap")
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: world.width, height: world.height)
                .clipped()
                .saturation(isSomber ? 0.28 : 1)
                .brightness(isSomber ? -0.22 : 0)
                .overlay {
                    LinearGradient(
                        colors: isSomber
                            ? [
                                Color(hex: "#050308")?.opacity(0.72) ?? .black.opacity(0.72),
                                Color(hex: "#1A0A12")?.opacity(0.45) ?? .black.opacity(0.45),
                                Color.black.opacity(0.55)
                            ]
                            : [
                                Color.black.opacity(0.12),
                                .clear,
                                Color.black.opacity(0.16)
                            ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .allowsHitTesting(false)

            ForEach(0..<7, id: \.self) { index in
                if dayWasSkipped(index) {
                    skippedDayGloom(at: points[index])
                }
            }

            pathLayer(points: points)

            ForEach(0..<7, id: \.self) { index in
                creatureInScene(index: index, points: points)
            }

            ForEach(0..<7, id: \.self) { index in
                dayMarker(index: index, at: points[index])
            }

            walkingHero(at: avatarPoint)
        }
        .frame(width: world.width, height: world.height)
    }

    private func skippedDayGloom(at point: CGPoint) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.black.opacity(isSomber ? 0.7 : 0.45),
                        Color(hex: "#120814")?.opacity(0.35) ?? .black.opacity(0.3),
                        .clear
                    ],
                    center: .center,
                    startRadius: 4,
                    endRadius: 70
                )
            )
            .frame(width: 130, height: 72)
            .position(point)
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }

    private func swampControl(from a: CGPoint, to b: CGPoint) -> CGPoint {
        CGPoint(
            x: (a.x + b.x) / 2 + 6,
            y: (a.y + b.y) / 2 + 10
        )
    }

    private func pathLayer(points: [CGPoint]) -> some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                let a = points[index]
                let b = points[index + 1]
                let swamp = index == swampFromIndex
                let unused = dayWasSkipped(index) && dayWasSkipped(index + 1)
                let control = swamp ? swampControl(from: a, to: b) : controlPoint(from: a, to: b)
                Path { path in
                    path.move(to: a)
                    path.addQuadCurve(to: b, control: control)
                }
                .stroke(
                    swamp
                        ? (Color(hex: "#1C2418")?.opacity(0.35) ?? .green.opacity(0.35))
                        : unused
                            ? (Color(hex: "#1A1210") ?? .black)
                            : (Color(hex: "#2A1810")?.opacity(0.35) ?? .brown.opacity(0.35)),
                    style: StrokeStyle(lineWidth: swamp ? 10 : 9, lineCap: .round, lineJoin: .round)
                )
                .offset(y: 2)

                Path { path in
                    path.move(to: a)
                    path.addQuadCurve(to: b, control: control)
                }
                .stroke(
                    swamp
                        ? (Color(hex: "#4A5C3A")?.opacity(0.28) ?? .green.opacity(0.28))
                        : unused
                            ? (Color(hex: "#3A2A22")?.opacity(0.4) ?? .brown.opacity(0.4))
                            : (Color(hex: "#C4A574")?.opacity(0.42) ?? .yellow.opacity(0.42)),
                    style: StrokeStyle(lineWidth: swamp ? 5 : 5, lineCap: .round, lineJoin: .round)
                )

                if !swamp {
                    Path { path in
                        path.move(to: a)
                        path.addQuadCurve(to: b, control: control)
                    }
                    .stroke(
                        Color(hex: "#9A9588")?.opacity(unused ? 0.18 : 0.55) ?? .gray.opacity(0.5),
                        style: StrokeStyle(lineWidth: 3.2, lineCap: .round, dash: [6, 8])
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func creatureInScene(index: Int, points: [CGPoint]) -> some View {
        let creature = TrailBiome.creature(forWeekday: index)
        let point = points[index]
        let side: CGFloat = index.isMultiple(of: 2) ? -1 : 1
        return creatureSprite(image: creature.image, name: creature.name, height: 72)
            .offset(x: fogDrift ? side * 2 : 0, y: bobbing ? -2 : 2)
            .position(x: point.x + side * 78, y: point.y - 4)
    }

    private func creatureSprite(image: String, name: String, height: CGFloat) -> some View {
        let hovering = hoveredCreature == name
        return VStack(spacing: 6) {
            if hovering {
                Text(name)
                    .font(.caption2.bold())
                    .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.72), in: Capsule())
                    .shadow(color: .black.opacity(0.5), radius: 3)
            }

            Image(image)
                .resizable()
                .renderingMode(.original)
                .interpolation(.high)
                .scaledToFit()
                .frame(height: height)
                .shadow(color: .black.opacity(0.45), radius: 5, y: 4)
        }
        .onHover { inside in
            withAnimation(.easeOut(duration: 0.15)) {
                hoveredCreature = inside ? name : (hoveredCreature == name ? nil : hoveredCreature)
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) {
                hoveredCreature = hoveredCreature == name ? nil : name
            }
        }
        .help(name)
        .accessibilityLabel(name)
    }

    private func dayMarker(index: Int, at point: CGPoint) -> some View {
        let seconds = weekdaySeconds[index]
        let used = seconds > 0
        let isToday = index == todayIndex
        let isPeak = index == peakIndex && used
        let isCastle = index == 6

        return VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(used ? (isPeak || isCastle ? Color(hex: "#F6E05E") ?? .yellow : Color(hex: "#ED8936") ?? .orange) : Color(hex: "#1A202C") ?? .gray)
                    .frame(width: isToday ? 22 : 14, height: isToday ? 22 : 14)
                    .shadow(color: used ? .orange.opacity(0.55) : .black.opacity(0.7), radius: used ? 5 : 2)
                if isToday {
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 26, height: 26)
                }
            }

            Text(isCastle ? "Castelo" : UserProgress.weekdayLabel(index: index))
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.8), radius: 2)
            Text("\(seconds / 60)m")
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .foregroundStyle(used ? (Color(hex: "#F6E05E") ?? .yellow) : .white.opacity(0.5))
        }
        .position(point)
        .offset(y: 22)
        .allowsHitTesting(false)
    }

    private func walkingHero(at point: CGPoint) -> some View {
        VStack(spacing: 0) {
            if usesCustomLook, let look {
                AssembledAvatarView(look: look, style: .fullBody)
                    .frame(width: 52, height: 76)
                    .offset(y: bobbing ? -6 : 1)
                    .shadow(color: .black.opacity(0.55), radius: 4, y: 3)
            } else {
                MedievalAvatarFaceView(avatar: avatar, size: 40, lineWidth: 1.5)
                    .offset(y: bobbing ? -6 : 1)
                    .shadow(color: .black.opacity(0.55), radius: 4, y: 3)
            }
            Capsule()
                .fill(.black.opacity(0.35))
                .frame(width: 16, height: 4)
                .offset(y: 2)
                .scaleEffect(x: bobbing ? 0.8 : 1.1)
        }
        .position(point)
        .offset(y: usesCustomLook ? -40 : -28)
        .animation(.easeInOut(duration: 0.35), value: bobbing)
        .allowsHitTesting(false)
    }

    /// Pontos colados na estrada do mapa: começa no centro-baixo e sobe em curva até o castelo à direita.
    private func trailPoints(in size: CGSize) -> [CGPoint] {
        let nodes: [(CGFloat, CGFloat)] = [
            (0.50, 0.91),
            (0.47, 0.78),
            (0.49, 0.66),
            (0.51, 0.55),
            (0.58, 0.46),
            (0.68, 0.36),
            (0.78, 0.27)
        ]
        return nodes.map { x, y in
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
        let control = index == swampFromIndex ? swampControl(from: a, to: b) : controlPoint(from: a, to: b)
        let u = 1 - t
        return CGPoint(
            x: u * u * a.x + 2 * u * t * control.x + t * t * b.x,
            y: u * u * a.y + 2 * u * t * control.y + t * t * b.y
        )
    }

    private func controlPoint(from a: CGPoint, to b: CGPoint) -> CGPoint {
        CGPoint(
            x: (a.x + b.x) / 2 + (b.y - a.y) * 0.12,
            y: (a.y + b.y) / 2 - abs(b.x - a.x) * 0.10
        )
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

#Preview("Sem uso hoje") {
    WeeklyTrailMapView(
        weekdaySeconds: [900, 1200, 0, 0, 0, 0, 0],
        avatar: .default,
        todayIndex: 3,
        peakIndex: 1,
        totalSessions: 6,
        successfulSessions: 4,
        currentStreak: 0,
        weeklyFocusSeconds: 2100
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
