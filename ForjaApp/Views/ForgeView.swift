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
                        onDismiss: { viewModel.dismissResult() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: viewModel.sessionState)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.configure(inventoryManager: inventory)
            }
            .onChange(of: scenePhase) { _, newPhase in
                viewModel.handleScenePhase(newPhase)
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
                    isSuccess: false
                )
                .frame(height: 220)

                TimerSetupView(
                    selectedMinutes: $viewModel.selectedMinutes,
                    selectedSeconds: $viewModel.selectedSeconds,
                    estimatedBars: viewModel.estimatedRewardBars,
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
                isSuccess: viewModel.sessionState == .success
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
        HStack {
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
                Text("Mantenha o foco. Forje barras.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            HStack(spacing: 6) {
                Text("🧱")
                Text("\(inventory.forgedBars)")
                    .font(.headline.bold())
                    .monospacedDigit()
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

    private var setupControlButton: some View {
        Button {
            if viewModel.sessionState == .idle {
                viewModel.prepareSession()
            }
            viewModel.igniteForge()
        } label: {
            Label("Ligar o Forno", systemImage: "flame.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(ForgePrimaryButtonStyle())
        .disabled(!viewModel.canStartForge)
    }
}

#Preview {
    ForgeView()
        .environmentObject(InventoryManager.shared)
}
