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

    private var isMonitoring = false

    func startMonitoring() {
        didLoseFocus = false
        isMonitoring = true
    }

    func stopMonitoring() {
        isMonitoring = false
    }

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        scenePhase = newPhase

        guard isMonitoring else { return }

        switch newPhase {
        case .background:
            didLoseFocus = true
        case .inactive:
            break
        case .active:
            break
        @unknown default:
            break
        }
    }

    func reset() {
        didLoseFocus = false
        isMonitoring = false
    }
}
