//
//  Focus Monitor.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Foundation
import SwiftUI
import Combine

@MainActor
final class FocusMonitor: ObservableObject {
    @Published private(set) var didLoseFocus = false
    @Published var scenePhase: ScenePhase = .active
    @Published private(set) var remainingGraceSeconds: Int = 0

    var graceSeconds: Int = 5

    private var isMonitoring = false
    private var graceTask: Task<Void, Never>?

    var effectiveGraceSeconds: Int {
        max(0, graceSeconds)
    }

    func startMonitoring() {
        didLoseFocus = false
        remainingGraceSeconds = 0
        isMonitoring = true
        graceTask?.cancel()
    }

    func stopMonitoring() {
        isMonitoring = false
        remainingGraceSeconds = 0
        graceTask?.cancel()
        graceTask = nil
    }

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        scenePhase = newPhase

        guard isMonitoring else { return }

        switch newPhase {
        case .background:
            beginGracePeriod()
        case .inactive:
            break
        case .active:
            cancelGracePeriod()
        @unknown default:
            break
        }
    }

    func reset() {
        didLoseFocus = false
        isMonitoring = false
        remainingGraceSeconds = 0
        graceTask?.cancel()
        graceTask = nil
    }

    private func beginGracePeriod() {
        graceTask?.cancel()
        let seconds = effectiveGraceSeconds
        if seconds <= 0 {
            didLoseFocus = true
            return
        }

        remainingGraceSeconds = seconds
        graceTask = Task { [weak self] in
            guard let self else { return }
            for remaining in stride(from: seconds, through: 1, by: -1) {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.remainingGraceSeconds = remaining
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            if Task.isCancelled { return }
            await MainActor.run {
                self.remainingGraceSeconds = 0
                if self.isMonitoring, self.scenePhase != .active {
                    self.didLoseFocus = true
                }
            }
        }
    }

    private func cancelGracePeriod() {
        graceTask?.cancel()
        graceTask = nil
        remainingGraceSeconds = 0
    }
}
