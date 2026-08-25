//
//  MainTabView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var inventory: InventoryManager

    var body: some View {
        TabView {
            ForgeView()
                .tabItem {
                    Label("Forja", systemImage: "flame.fill")
                }

            TrailMapView()
                .tabItem {
                    Label("Trilha", systemImage: "map.fill")
                }

            ShopView()
                .tabItem {
                    Label("Loja", systemImage: "cart.fill")
                }

            SocialHubView()
                .tabItem {
                    Label("Guilda", systemImage: "shield.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "#F6AD55") ?? .orange)
    }
}

#Preview {
    MainTabView()
        .environmentObject(InventoryManager.shared)
        .environmentObject(FirebaseManager.shared)
}
