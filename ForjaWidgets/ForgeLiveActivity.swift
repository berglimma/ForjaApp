//
//  ForgeLiveActivity.swift
//  ForjaWidgets
//

import ActivityKit
import SwiftUI
import WidgetKit

struct ForgeLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ForgeActivityAttributes.self) { context in
            lockScreen(context: context)
                .activityBackgroundTint(Color(hex: "#1A202C"))
                .activitySystemActionForegroundColor(Color(hex: "#F6AD55"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.avatarEmoji)
                        .font(.title)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.formattedRemaining)
                        .font(.title3.monospacedDigit().bold())
                        .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.sessionTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(Color(hex: "#ED8936") ?? .orange)
                }
            } compactLeading: {
                Text("🔥")
            } compactTrailing: {
                Text(context.state.formattedRemaining)
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            } minimal: {
                Text("🔥")
            }
        }
    }

    private func lockScreen(context: ActivityViewContext<ForgeActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            Text(context.state.avatarEmoji)
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.sessionTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.formattedRemaining)
                    .font(.title2.monospacedDigit().bold())
                ProgressView(value: context.state.progress)
                    .tint(Color(hex: "#F6AD55") ?? .orange)
            }
            Spacer()
            Text("FORJA")
                .font(.caption.bold())
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
        }
        .padding()
    }
}
