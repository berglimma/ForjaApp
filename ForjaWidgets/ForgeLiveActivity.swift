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
                    liveAvatar(context.state.avatarImageName, size: 44)
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
                liveAvatar(context.state.avatarImageName, size: 20)
            } compactTrailing: {
                Text(context.state.formattedRemaining)
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            } minimal: {
                liveAvatar(context.state.avatarImageName, size: 18)
            }
        }
    }

    private func lockScreen(context: ActivityViewContext<ForgeActivityAttributes>) -> some View {
        HStack(spacing: 14) {
            liveAvatar(context.state.avatarImageName, size: 48)
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

    private func liveAvatar(_ imageName: String, size: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .renderingMode(.original)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
