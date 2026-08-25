//
//  ForgeView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI

struct ForgeView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @StateObject private var viewModel = ForgeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showAvatarPicker = false

    private var isSetupState: Bool {
        viewModel.sessionState == .idle || viewModel.sessionState == .ready
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ForgeBackgroundView(
                    isActive: viewModel.sessionState == .forging,
                    isFailed: isFailedState
                )
                MedievalBackdropView(torchlit: viewModel.sessionState == .forging)
                    .opacity(0.55)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    headerBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)

                    if isSetupState {
                        setupContent
                    } else {
                        activeSessionContent
                    }
                }

                if viewModel.showResultOverlay {
                    ResultOverlayView(
                        state: viewModel.sessionState,
                        barsEarned: viewModel.barsEarnedOnSuccess,
                        avatar: inventory.progress.selectedAvatar,
                        onDismiss: { viewModel.dismissResult() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: viewModel.sessionState)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.configure(inventoryManager: inventory)
                viewModel.alignDurationToChallenge()
            }
            .onChange(of: scenePhase) { _, newPhase in
                viewModel.handleScenePhase(newPhase)
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedID: inventory.progress.selectedAvatarID) { avatar in
                    inventory.selectAvatar(avatar)
                    showAvatarPicker = false
                }
            }
        }
    }

    private var setupContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ForgeSceneView(
                    progress: 0,
                    isForging: false,
                    isFailed: false,
                    isSuccess: false,
                    anvilSkinID: inventory.progress.equippedAnvilSkinID,
                    furnaceSkinID: inventory.progress.equippedFurnaceSkinID
                )
                .frame(height: 220)

                TimerSetupView(
                    selectedMinutes: $viewModel.selectedMinutes,
                    selectedSeconds: $viewModel.selectedSeconds,
                    estimatedBars: viewModel.estimatedRewardBars,
                    lifetimeBars: inventory.progress.lifetimeBars,
                    matchesPreset: viewModel.matchesPreset,
                    onSelectPreset: viewModel.applyPreset,
                    isDisabled: false
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            setupControlButton
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background {
                    LinearGradient(
                        colors: [
                            Color(hex: "#0D1117")?.opacity(0) ?? .clear,
                            Color(hex: "#0D1117") ?? .black
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
        }
    }

    private var activeSessionContent: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            ForgeSceneView(
                progress: viewModel.timerService.progress,
                isForging: viewModel.sessionState == .forging,
                isFailed: isFailedState,
                isSuccess: viewModel.sessionState == .success,
                anvilSkinID: inventory.progress.equippedAnvilSkinID,
                furnaceSkinID: inventory.progress.equippedFurnaceSkinID
            )
            .frame(height: 260)
            .padding(.horizontal, 24)

            timerSection
                .padding(.horizontal, 24)

            controlSection
                .padding(.horizontal, 24)

            Spacer(minLength: 8)
        }
    }

    private var isFailedState: Bool {
        if case .failed = viewModel.sessionState { return true }
        return false
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button { showAvatarPicker = true } label: {
                Text(inventory.progress.selectedAvatar.emoji)
                    .font(.system(size: 34))
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.08), in: Circle())
                    .overlay {
                        Circle().stroke(Color(hex: inventory.progress.selectedAvatar.accentHex) ?? .orange, lineWidth: 2)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Trocar avatar")

            VStack(alignment: .leading, spacing: 4) {
                Text("FORJA")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#FBD38D") ?? .yellow, Color(hex: "#ED8936") ?? .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text(
                    viewModel.sessionState == .forging
                        ? MedievalFocusCopy.forgingLine(avatar: inventory.progress.selectedAvatar)
                        : MedievalFocusCopy.forgeIdleSubtitle(
                            avatar: inventory.progress.selectedAvatar,
                            challengeName: OreChallengeLadder.active(lifetimeBars: inventory.progress.lifetimeBars).name
                        )
                )
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Text("🪨")
                    Text("\(inventory.ore)")
                        .font(.headline.bold())
                        .monospacedDigit()
                }
                Text("\(inventory.progress.lifetimeBars) barras")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var timerSection: some View {
        switch viewModel.sessionState {
        case .forging, .success:
            VStack(spacing: 8) {
                Text(viewModel.timerService.formattedRemaining)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: viewModel.timerService.remainingSeconds)

                if viewModel.remainingGraceSeconds > 0 {
                    Text("Graça: \(viewModel.remainingGraceSeconds)s para voltar à forja")
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                }

                ProgressView(value: viewModel.timerService.progress)
                    .tint(Color(hex: "#F6AD55") ?? .orange)
                    .scaleEffect(x: 1, y: 2.5, anchor: .center)
                    .padding(.horizontal, 8)
                    .animation(.linear(duration: 0.9), value: viewModel.timerService.progress)
            }
        case .failed:
            EmptyView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var controlSection: some View {
        switch viewModel.sessionState {
        case .forging:
            Button(role: .destructive) {
                viewModel.cancelForge()
            } label: {
                Label("Apagar o Fogo", systemImage: "xmark.circle")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(ForgeSecondaryButtonStyle())
            .padding(.bottom, 8)

        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var setupControlButton: some View {
        Button {
            viewModel.startForge()
        } label: {
            Label("Ligar o Forno", systemImage: "flame.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
        }
        .buttonStyle(ForgePrimaryButtonStyle())
        .disabled(!viewModel.canStartForge)
        .alert("Fornalha em pausa", isPresented: blockedAlertBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.sessionBlockedMessage ?? "")
        }
    }

    private var blockedAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.sessionBlockedMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.sessionBlockedMessage = nil
                }
            }
        )
    }
}

#Preview {
    ForgeView()
        .environmentObject(InventoryManager.shared)
}
