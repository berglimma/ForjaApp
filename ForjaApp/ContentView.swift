//
//  ContentView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var inventory: InventoryManager

    var body: some View {
        Group {
            if inventory.progress.onboardingCompleted {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: inventory.progress.onboardingCompleted)
    }
}

#Preview {
    ContentView()
        .environmentObject(InventoryManager.shared)
        .environmentObject(FirebaseManager.shared)
}
