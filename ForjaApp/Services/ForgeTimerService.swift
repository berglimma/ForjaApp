//
//  ForgeTimerService.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Foundation
import Combine

@MainActor
final class ForgeTimerService: ObservableObject {
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var totalSeconds: Int = 0
    @Published private(set) var isRunning = false

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var formattedRemaining: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var timer: AnyCancellable?

    func configure(totalSeconds seconds: Int) {
        let clamped = max(1, seconds)
        totalSeconds = clamped
        remainingSeconds = clamped
        isRunning = false
    }

    func configure(minutes: Int, seconds: Int = 0) {
        configure(totalSeconds: minutes * 60 + seconds)
    }

    func start(onComplete: @escaping () -> Void) {
        guard totalSeconds > 0, !isRunning else { return }
        isRunning = true

        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                if self.remainingSeconds <= 1 {
                    self.remainingSeconds = 0
                    self.stop()
                    onComplete()
                    return
                }

                self.remainingSeconds -= 1
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }

    func reset() {
        stop()
        remainingSeconds = totalSeconds
    }
}
