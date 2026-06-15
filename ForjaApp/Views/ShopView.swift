//
//  ShopView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @State private var purchaseAlert: PurchaseAlert?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceBanner

                    ForEach(ShopCatalog.items) { item in
                        ShopItemRow(
                            item: item,
                            ownedCount: inventory.progress.ownedCount(for: item.id),
                            canAfford: inventory.canAfford(item),
                            onPurchase: { attemptPurchase(item) }
                        )
                    }
                }
                .padding()
            }
            .background((Color(hex: "#0D1117") ?? .black).ignoresSafeArea())
            .navigationTitle("Loja do Ferreiro")
            .alert(item: $purchaseAlert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var balanceBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Seu saldo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text("🧱")
                    Text("\(inventory.forgedBars) barras")
                        .font(.title2.bold())
                }
            }
            Spacer()
            Image(systemName: "cart.fill")
                .font(.title2)
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#2D2416")?.opacity(0.9) ?? .brown.opacity(0.3),
                    Color(hex: "#1A202C")?.opacity(0.9) ?? .gray.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func attemptPurchase(_ item: ShopItem) {
        if inventory.purchase(item: item) {
            purchaseAlert = PurchaseAlert(
                title: "Item adquirido!",
                message: "Você trocou \(item.price) barras por \(item.name) \(item.emoji)"
            )
        } else {
            purchaseAlert = PurchaseAlert(
                title: "Barras insuficientes",
                message: "Você precisa de \(item.price) barras. Complete mais forjas para juntar!"
            )
        }
    }
}

struct ShopItemRow: View {
    let item: ShopItem
    let ownedCount: Int
    let canAfford: Bool
    let onPurchase: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: item.swiftUIColors.isEmpty ? [.gray, .black] : item.swiftUIColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Text(item.emoji)
                    .font(.system(size: 30))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    Text(item.rarity.label)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(item.rarity.color.opacity(0.25), in: Capsule())
                        .foregroundStyle(item.rarity.color)
                }

                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if ownedCount > 0 {
                    Text("Você possui: \(ownedCount)")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer(minLength: 8)

            Button(action: onPurchase) {
                VStack(spacing: 2) {
                    Text("🧱 \(item.price)")
                        .font(.caption.bold())
                    Text("Trocar")
                        .font(.caption2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(canAfford ? Color(hex: "#C05621") ?? .orange : .gray)
            .disabled(!canAfford)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct CollectibleCard: View {
    let item: ShopItem
    let ownedCount: Int

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: item.swiftUIColors.isEmpty ? [.gray, .black] : item.swiftUIColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)

                Text(item.emoji)
                    .font(.system(size: 44))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if ownedCount > 1 {
                    Text("×\(ownedCount)")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.5), in: Capsule())
                        .padding(8)
                }
            }

            Text(item.name)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(item.rarity.label)
                .font(.caption2)
                .foregroundStyle(item.rarity.color)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct PurchaseAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    ShopView()
        .environmentObject(InventoryManager.shared)
}
