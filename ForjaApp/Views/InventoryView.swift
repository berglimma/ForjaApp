//
//  InventoryView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject private var inventory: InventoryManager

    private var groupedCollectibles: [(item: ShopItem, count: Int)] {
        let grouped = Dictionary(grouping: inventory.progress.ownedCollectibles, by: \.itemID)
        return grouped.compactMap { itemID, entries in
            guard let item = ShopCatalog.item(for: itemID) else { return nil }
            return (item: item, count: entries.count)
        }
        .sorted { $0.item.price > $1.item.price }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsHeader

                    barsSection

                    if groupedCollectibles.isEmpty {
                        emptyState
                    } else {
                        collectiblesGrid
                    }
                }
                .padding()
            }
            .background((Color(hex: "#0D1117") ?? .black).ignoresSafeArea())
            .navigationTitle("Inventário")
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(title: "Sessões", value: "\(inventory.progress.successfulSessions)", icon: "checkmark.seal.fill")
            StatCard(title: "Sequência", value: "\(inventory.progress.currentStreak)", icon: "flame.fill")
            StatCard(title: "Recorde", value: "\(inventory.progress.bestStreak)", icon: "trophy.fill")
        }
    }

    private var barsSection: some View {
        HStack {
            Text("🧱")
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 4) {
                Text("Barras Forjadas")
                    .font(.headline)
                Text("\(inventory.forgedBars) disponíveis para trocar na loja")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("📦")
                .font(.system(size: 56))
            Text("Nenhum colecionável ainda")
                .font(.headline)
            Text("Complete uma forja e visite a loja para trocar suas barras por itens raros.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 48)
    }

    private var collectiblesGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Colecionáveis")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(groupedCollectibles, id: \.item.id) { entry in
                    CollectibleCard(item: entry.item, ownedCount: entry.count)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            Text(value)
                .font(.title3.bold())
                .monospacedDigit()
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    InventoryView()
        .environmentObject(InventoryManager.shared)
}
