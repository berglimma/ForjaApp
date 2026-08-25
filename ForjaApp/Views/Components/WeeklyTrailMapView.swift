//
//  WeeklyTrailMapView.swift
//  ForjaApp
//

import SwiftUI

struct WeeklyTrailMapView: View {
    let weekdaySeconds: [Int]
    let avatar: MedievalAvatar
    let todayIndex: Int
    let peakIndex: Int

    private var maxSeconds: Int {
        max(weekdaySeconds.max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Trilha da semana")
                    .font(.headline)
                Spacer()
                Text("Pico: \(UserProgress.weekdayFullLabel(index: peakIndex))")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }

            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                let points = trailPoints(in: CGSize(width: width, height: height))

                ZStack {
                    Path { path in
                        guard let first = points.first else { return }
                        path.move(to: first)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(
                        Color(hex: "#744210") ?? .brown,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                    )

                    Path { path in
                        guard let first = points.first else { return }
                        path.move(to: first)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(
                        Color(hex: "#D69E2E") ?? .yellow,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 8])
                    )

                    ForEach(0..<7, id: \.self) { index in
                        let point = points[index]
                        let ratio = CGFloat(weekdaySeconds[index]) / CGFloat(maxSeconds)
                        DayTrailNode(
                            label: UserProgress.weekdayLabel(index: index),
                            minutes: weekdaySeconds[index] / 60,
                            isToday: index == todayIndex,
                            isPeak: index == peakIndex && weekdaySeconds[index] > 0,
                            flameHeight: 10 + ratio * 28
                        )
                        .position(point)

                        if index == todayIndex {
                            Text(avatar.emoji)
                                .font(.system(size: 34))
                                .shadow(radius: 6)
                                .offset(y: -46)
                                .position(point)
                        }
                    }
                }
            }
            .frame(height: 220)

            Text("\(avatar.name) caminha pelos dias em que você mais forjou. O marco dourado é o dia de maior foco.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func trailPoints(in size: CGSize) -> [CGPoint] {
        let xs: [CGFloat] = [0.08, 0.22, 0.38, 0.52, 0.66, 0.80, 0.93]
        let ys: [CGFloat] = [0.72, 0.38, 0.62, 0.28, 0.58, 0.34, 0.48]
        return zip(xs, ys).map { x, y in
            CGPoint(x: x * size.width, y: y * size.height)
        }
    }
}

private struct DayTrailNode: View {
    let label: String
    let minutes: Int
    let isToday: Bool
    let isPeak: Bool
    let flameHeight: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: isPeak
                            ? [Color(hex: "#F6E05E") ?? .yellow, Color(hex: "#DD6B20") ?? .orange]
                            : [Color(hex: "#ED8936") ?? .orange, Color(hex: "#C05621") ?? .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 8, height: flameHeight)
                .opacity(minutes > 0 ? 1 : 0.2)

            Circle()
                .fill(isToday ? (Color(hex: "#F6E05E") ?? .yellow) : (Color(hex: "#C05621") ?? .orange))
                .frame(width: isToday ? 22 : 16, height: isToday ? 22 : 16)
                .overlay {
                    Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                }

            Text(label)
                .font(.caption2.bold())
            Text("\(minutes)m")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
