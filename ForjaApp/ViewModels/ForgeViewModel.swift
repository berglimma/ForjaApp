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
    @Published var sessionBlockedMessage: String?

    let timerService = ForgeTimerService()
    let focusMonitor = FocusMonitor()

    private var inventoryManager: InventoryManager?
    private var focusCancellable: AnyCancellable?
    private var timerTickCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var sessionStartedTotalSeconds = 0

    init() {
        timerService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        focusMonitor.objectWillChange
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
        OreChallengeLadder.adjustedReward(
            base: ForgeDurationOption.rewardBars(for: totalDurationSeconds),
            durationSeconds: totalDurationSeconds,
            lifetimeBars: inventoryManager?.progress.lifetimeBars ?? 0
        )
    }

    var remainingGraceSeconds: Int {
        focusMonitor.remainingGraceSeconds
    }

    func applyPreset(_ preset: ForgeDurationOption) {
        selectedMinutes = preset.minutes
        selectedSeconds = preset.seconds
    }

    func matchesPreset(_ preset: ForgeDurationOption) -> Bool {
        selectedMinutes == preset.minutes && selectedSeconds == preset.seconds
    }

    func alignDurationToChallenge() {
        let minMinutes = OreChallengeLadder.active(lifetimeBars: inventoryManager?.progress.lifetimeBars ?? 0).minFocusMinutes
        if selectedMinutes < minMinutes {
            selectedMinutes = minMinutes
            selectedSeconds = 0
        }
    }

    func configure(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }

    func prepareSession() {
        timerService.configure(totalSeconds: totalDurationSeconds)
        sessionState = .ready
        showResultOverlay = false
        sessionBlockedMessage = nil
        focusMonitor.reset()
    }

    func startForge() {
        if inventoryManager == nil {
            inventoryManager = InventoryManager.shared
        }

        guard sessionState == .ready || sessionState == .idle else { return }
        guard canStartForge else { return }

        inventoryManager?.rollPeriodsIfNeeded()
        let progress = inventoryManager?.progress ?? .empty
        if !EntitlementStore.shared.canStartSession(progress: progress) {
            sessionBlockedMessage = "Limite diário de \(EntitlementLimits.freeDailySessions) sessões atingido. Assine Mestre Ferreiro para forjar sem limite."
            return
        }

        let challenge = OreChallengeLadder.active(lifetimeBars: progress.lifetimeBars)
        if totalDurationSeconds < challenge.minFocusMinutes * 60 {
            sessionBlockedMessage = MedievalFocusCopy.blockedTooShort(
                challengeName: challenge.name,
                minutes: challenge.minFocusMinutes
            )
            return
        }

        timerService.configure(totalSeconds: totalDurationSeconds)
        sessionStartedTotalSeconds = totalDurationSeconds
        sessionState = .forging
        showResultOverlay = false
        sessionBlockedMessage = nil
        let challengeGrace = min(progress.graceSeconds, challenge.graceCap)
        focusMonitor.graceSeconds = progress.isHardcoreEnabled ? 0 : challengeGrace
        focusMonitor.startMonitoring()
        UIApplication.shared.isIdleTimerDisabled = true

        let displayName = progress.displayName
        let avatar = progress.selectedAvatar
        let totalSeconds = totalDurationSeconds

        Task { @MainActor in
            LiveActivityController.shared.start(
                totalSeconds: totalSeconds,
                displayName: displayName,
                avatarEmoji: avatar.emoji,
                sessionTitle: MedievalFocusCopy.liveActivityTitle(avatar: avatar)
            )
        }

        focusCancellable?.cancel()
        focusCancellable = focusMonitor.$didLoseFocus
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in
                self?.handleFocusLost()
            }

        timerTickCancellable?.cancel()
        timerTickCancellable = timerService.$remainingSeconds
            .dropFirst()
            .sink { [weak self] remaining in
                guard let self, self.sessionState == .forging else { return }
                LiveActivityController.shared.update(
                    remainingSeconds: remaining,
                    totalSeconds: self.sessionStartedTotalSeconds,
                    displayName: displayName,
                    avatarEmoji: avatar.emoji
                )
            }

        timerService.start { [weak self] in
            self?.handleForgeComplete()
        }
    }

    func igniteForge() {
        startForge()
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
        timerTickCancellable?.cancel()
        timerTickCancellable = nil
        LiveActivityController.shared.end()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func handleScenePhase(_ phase: ScenePhase) {
        focusMonitor.handleScenePhaseChange(phase)
    }
}
