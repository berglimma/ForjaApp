//
//  FocusTomeChartView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Charts
import SwiftUI

struct FocusTimeChartView: View {
    let segments: [FocusChartSegment]

    private var hasData: Bool {
        segments.contains { $0.seconds > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tempo de foco")
                .font(.headline)

            if hasData {
                chart
                legend
            } else {
                Text("Complete ou tente forjas para ver seu gráfico de foco.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            }
        }
    }

    private var chart: some View {
        Chart(segments) { segment in
            BarMark(
                x: .value("Minutos", Double(segment.seconds) / 60.0),
                y: .value("Tipo", segment.title)
            )
            .foregroundStyle(Color(hex: segment.colorHex) ?? .orange)
            .cornerRadius(6)
        }
        .frame(height: 140)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            ForEach(segments) { segment in
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: segment.colorHex) ?? .orange)
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(segment.title)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(segment.minutesLabel)
                            .font(.caption.bold())
                    }
                }
            }
        }
    }
}

#Preview {
    FocusTimeChartView(segments: UserProgress.empty.chartSegments)
        .padding()
        .background(Color(hex: "#0D1117") ?? .black)
}
