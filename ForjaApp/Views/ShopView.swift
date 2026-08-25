//
//  ShopView.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI
import StoreKit
import UIKit

struct ShopView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @StateObject private var store = StoreManager.shared
    @StateObject private var entitlements = EntitlementStore.shared
    @State private var purchaseAlert: PurchaseAlert?
    @State private var selectedTab: ShopTab = .oficina
    @State private var showPaywall = false
    @State private var shareImage: IdentifiableImage?

    private var theme: ShopThemePalette {
        ShopThemePalette.palette(for: inventory.progress.equippedShopThemeID)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    dualBalanceBanner
                    economyNote

                    Picker("Loja", selection: $selectedTab) {
                        ForEach(ShopTab.allCases) { tab in
                            Text(tab.title).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch selectedTab {
                    case .oficina:
                        oficinaSection
                    case .tesouro:
                        tesouroSection
                    case .sazonal:
                        seasonalSection
                    }
                }
                .padding()
            }
            .background((Color(hex: theme.backgroundHex) ?? .black).ignoresSafeArea())
            .navigationTitle("Loja do Ferreiro")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Mestre Ferreiro") { showPaywall = true }
                }
            }
            .alert(item: $purchaseAlert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showPaywall) {
                SubscriptionPaywallView()
                    .environmentObject(inventory)
            }
            .sheet(item: $shareImage) { wrapper in
                ShareSheet(items: [wrapper.image])
            }
            .task { await store.refresh() }
        }
    }

    private var dualBalanceBanner: some View {
        HStack(spacing: 12) {
            currencyChip(emoji: "🪨", value: inventory.ore, label: "Minério")
            currencyChip(emoji: "💎", value: inventory.gems, label: "Gemas")
        }
    }

    private func currencyChip(emoji: String, value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                Text(emoji)
                Text("\(value)")
                    .font(.title3.bold())
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(hex: theme.cardHex) ?? .gray.opacity(0.3),
                    Color(hex: "#1A202C")?.opacity(0.9) ?? .gray.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private var economyNote: some View {
        Text("Minério só nasce de foco. Gemas se compram. Colecionáveis raros não se vendem por dinheiro — o flex continua merecido.")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var oficinaSection: some View {
        VStack(spacing: 12) {
            ForEach(ShopCatalog.items) { item in
                ShopItemRow(
                    item: item,
                    ownedCount: inventory.progress.ownedCount(for: item.id),
                    canAfford: inventory.canAfford(item),
                    onPurchase: { attemptOrePurchase(item) },
                    onShare: item.rarity == .lendario && inventory.progress.ownedCount(for: item.id) > 0
                        ? { shareLegendary(item) }
                        : nil
                )
            }
        }
    }

    private var tesouroSection: some View {
        VStack(spacing: 16) {
            gemPacks
            ForEach(CosmeticCatalog.items.filter { $0.kind != .seasonalPack }) { item in
                CosmeticRow(
                    item: item,
                    owned: inventory.progress.ownsCosmetic(item.id) || (item.requiresSubscription && entitlements.isPremium),
                    equipped: isEquipped(item),
                    canAfford: inventory.canAffordCosmetic(item),
                    isPremiumLocked: item.requiresSubscription && !entitlements.isPremium,
                    onBuy: { buyCosmetic(item) },
                    onEquip: { inventory.equipCosmetic(item) }
                )
            }
        }
    }

    private var gemPacks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gemas (IAP)")
                .font(.headline)
            ForEach([StoreProductID.gemsSmall, StoreProductID.gemsMedium, StoreProductID.gemsLarge], id: \.self) { id in
                let amount = StoreProductID.gemAmount(for: id)
                HStack {
                    Text("💎 \(amount) gemas")
                        .font(.subheadline.bold())
                    Spacer()
                    if let product = store.product(id: id) {
                        Button(product.displayPrice) {
                            Task {
                                if await store.purchase(product) {
                                    purchaseAlert = PurchaseAlert(
                                        title: "Gemas adicionadas",
                                        message: "+\(amount) gemas na bolsa. Elas não compram colecionáveis da oficina."
                                    )
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "#6B46C1") ?? .purple)
                    } else {
                        Text("Em breve")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var seasonalSection: some View {
        VStack(spacing: 12) {
            Text("Pacotes sazonais vendidos direto. Não mexem no minério nem nas barras forjadas.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(CosmeticCatalog.seasonalPacks) { pack in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(pack.emoji)
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(pack.name)
                                .font(.headline)
                            Text(pack.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if inventory.progress.ownsCosmetic(pack.id) {
                        Text("Pacote desbloqueado")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                        Button("Usar tema") {
                            inventory.equipCosmetic(pack)
                        }
                        .buttonStyle(ForgeSecondaryButtonStyle())
                    } else if let product = store.product(id: pack.productID ?? "") {
                        Button("Comprar · \(product.displayPrice)") {
                            Task { _ = await store.purchase(product) }
                        }
                        .buttonStyle(ForgePrimaryButtonStyle())
                    } else {
                        Text("Disponível na App Store quando o IAP estiver publicado.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    LinearGradient(colors: pack.swiftUIColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
        }
    }

    private func isEquipped(_ item: CosmeticItem) -> Bool {
        switch item.kind {
        case .anvilSkin: return inventory.progress.equippedAnvilSkinID == item.id
        case .furnaceSkin: return inventory.progress.equippedFurnaceSkinID == item.id
        case .shopTheme, .seasonalPack: return inventory.progress.equippedShopThemeID == item.id
        }
    }

    private func attemptOrePurchase(_ item: ShopItem) {
        if inventory.purchase(item: item) {
            purchaseAlert = PurchaseAlert(
                title: "Item adquirido!",
                message: "Você trocou \(item.price) minério por \(item.name) \(item.emoji)"
            )
        } else {
            purchaseAlert = PurchaseAlert(
                title: "Minério insuficiente",
                message: "Você precisa de \(item.price) minério. Complete mais forjas — gemas não compram este item."
            )
        }
    }

    private func buyCosmetic(_ item: CosmeticItem) {
        if item.requiresSubscription && !entitlements.isPremium {
            showPaywall = true
            return
        }
        if inventory.purchaseCosmetic(item) {
            inventory.equipCosmetic(item)
            purchaseAlert = PurchaseAlert(title: "Skin desbloqueada", message: item.name)
        } else {
            purchaseAlert = PurchaseAlert(title: "Gemas insuficientes", message: "Compre gemas na aba Tesouro.")
        }
    }

    private func shareLegendary(_ item: ShopItem) {
        if let image = AchievementShareRenderer.renderLegendaryCard(
            itemName: item.name,
            emoji: item.emoji,
            displayName: inventory.progress.displayName,
            lifetimeBars: inventory.progress.lifetimeBars
        ) {
            shareImage = IdentifiableImage(image: image)
        }
    }
}

enum ShopTab: String, CaseIterable, Identifiable {
    case oficina
    case tesouro
    case sazonal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .oficina: return "Oficina"
        case .tesouro: return "Tesouro"
        case .sazonal: return "Sazonal"
        }
    }
}

struct ShopItemRow: View {
    let item: ShopItem
    let ownedCount: Int
    let canAfford: Bool
    let onPurchase: () -> Void
    var onShare: (() -> Void)? = nil

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

            VStack(spacing: 6) {
                Button(action: onPurchase) {
                    VStack(spacing: 2) {
                        Text("🪨 \(item.price)")
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

                if let onShare {
                    Button("Stories", action: onShare)
                        .font(.caption2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct CosmeticRow: View {
    let item: CosmeticItem
    let owned: Bool
    let equipped: Bool
    let canAfford: Bool
    let isPremiumLocked: Bool
    let onBuy: () -> Void
    let onEquip: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(item.emoji)
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if equipped {
                Text("Equipado")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            } else if owned {
                Button("Equipar", action: onEquip)
                    .buttonStyle(.bordered)
            } else if isPremiumLocked {
                Button("Assinar", action: onBuy)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#B7791F") ?? .yellow)
            } else {
                Button("💎 \(item.gemPrice)", action: onBuy)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#6B46C1") ?? .purple)
                    .disabled(!canAfford && item.gemPrice > 0)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ShopView()
        .environmentObject(InventoryManager.shared)
}
