//
//  ContentView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(InventoryManager.shared)
        .environmentObject(FirebaseManager.shared)
}
