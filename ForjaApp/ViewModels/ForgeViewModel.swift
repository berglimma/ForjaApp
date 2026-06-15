//
//  ForgeViewModel.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Combine
import SwiftUI
import UIKit

@MainActor
final class ForgeViewModel: ObservableObject {
    @Published var sessionState: ForgeSessionState = .idle
    @Published var selectedMinutes: Int = 25
    @Published var selectedSeconds: Int = 0
    @Published var barsEarnedOnSuccess: Int = 0
    @Published var showResultOverlay = false

    let timerService = ForgeTimerService()
    let focusMonitor = FocusMonitor()

    private var inventoryManager: InventoryManager?
    private var focusCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var sessionStartedTotalSeconds = 0

    init() {
        timerService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var totalDurationSeconds: Int {
        selectedMinutes * 60 + selectedSeconds
    }

    var canStartForge: Bool {
        totalDurationSeconds > 0
    }

    var estimatedRewardBars: Int {
        ForgeDurationOption.rewardBars(for: totalDurationSeconds)
    }

    func applyPreset(_ preset: ForgeDurationOption) {
        selectedMinutes = preset.minutes
        selectedSeconds = preset.seconds
    }

    func matchesPreset(_ preset: ForgeDurationOption) -> Bool {
        selectedMinutes == preset.minutes && selectedSeconds == preset.seconds
    }

    func configure(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }

    func prepareSession() {
        timerService.configure(totalSeconds: totalDurationSeconds)
        sessionState = .ready
        showResultOverlay = false
        focusMonitor.reset()
    }

    func igniteForge() {
        guard sessionState == .ready || sessionState == .idle else { return }
        guard canStartForge else { return }

        timerService.configure(totalSeconds: totalDurationSeconds)
        sessionStartedTotalSeconds = totalDurationSeconds
        sessionState = .forging
        showResultOverlay = false
        focusMonitor.startMonitoring()
        UIApplication.shared.isIdleTimerDisabled = true

        focusCancellable = focusMonitor.$didLoseFocus
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in
                self?.handleFocusLost()
            }

        timerService.start { [weak self] in
            self?.handleForgeComplete()
        }
    }

    func cancelForge() {
        guard sessionState == .forging else { return }
        let elapsed = elapsedFocusSeconds
        endSession()
        inventoryManager?.failForge(
            focusSeconds: elapsed,
            plannedSeconds: sessionStartedTotalSeconds
        )
        sessionState = .failed(reason: .cancelled)
        showResultOverlay = true
    }

    func dismissResult() {
        showResultOverlay = false
        sessionState = .idle
        timerService.reset()
        focusMonitor.reset()
    }

    private func handleFocusLost() {
        guard sessionState == .forging else { return }
        let elapsed = elapsedFocusSeconds
        endSession()
        inventoryManager?.failForge(
            focusSeconds: elapsed,
            plannedSeconds: sessionStartedTotalSeconds
        )
        sessionState = .failed(reason: .leftApp)
        showResultOverlay = true
    }

    private func handleForgeComplete() {
        guard sessionState == .forging else { return }

        let bars = estimatedRewardBars
        barsEarnedOnSuccess = bars
        endSession()
        inventoryManager?.completeForge(barsEarned: bars, focusSeconds: sessionStartedTotalSeconds)
        sessionState = .success
        showResultOverlay = true
    }

    private var elapsedFocusSeconds: Int {
        max(0, sessionStartedTotalSeconds - timerService.remainingSeconds)
    }

    private func endSession() {
        timerService.stop()
        focusMonitor.stopMonitoring()
        focusCancellable?.cancel()
        focusCancellable = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func handleScenePhase(_ phase: ScenePhase) {
        focusMonitor.handleScenePhaseChange(phase)
    }
}
