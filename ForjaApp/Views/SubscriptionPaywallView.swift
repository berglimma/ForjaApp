//
//  SubscriptionPaywallView.swift
//  ForjaApp
//

import SwiftUI
import StoreKit

struct SubscriptionPaywallView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @StateObject private var store = StoreManager.shared
    @StateObject private var entitlements = EntitlementStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("👑")
                        .font(.system(size: 56))
                    Text("Mestre Ferreiro")
                        .font(.largeTitle.bold())
                    Text("Assinatura mensal ou anual. Trial de 7 dias no onboarding.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if entitlements.isTrialActive {
                        Text("Trial ativo · \(entitlements.trialDaysRemaining) dia(s) restantes")
                            .font(.caption.bold())
                            .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                    } else if entitlements.isStoreKitSubscribed {
                        Text("Assinatura ativa")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        perk("Skins de bigorna e fornalha")
                        perk("Estatísticas avançadas e horário de pico")
                        perk("Temas de loja exclusivos")
                        perk("Backup ilimitado na nuvem")
                        perk("Sessões diárias ilimitadas")
                        perk("Modo tolerante de até 20s")
                        perk("Hardcore mode incluso")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    if let yearly = store.yearlyProduct {
                        Button {
                            Task { _ = await store.purchase(yearly) }
                        } label: {
                            VStack {
                                Text("Anual · \(yearly.displayPrice)")
                                    .font(.headline)
                                Text("Melhor valor")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(ForgePrimaryButtonStyle())
                    }

                    if let monthly = store.monthlyProduct {
                        Button {
                            Task { _ = await store.purchase(monthly) }
                        } label: {
                            Text("Mensal · \(monthly.displayPrice)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(ForgeSecondaryButtonStyle())
                    }

                    if store.monthlyProduct == nil && store.yearlyProduct == nil {
                        Text("Produtos ainda não carregados. Configure o arquivo Products.storekit no scheme do Xcode ou publique os IAPs no App Store Connect.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button("Restaurar compras") {
                        Task { await store.restore() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let error = store.lastError {
                        Text(error)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .background((Color(hex: "#0D1117") ?? .black).ignoresSafeArea())
            .navigationTitle("Assinatura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .task { await store.refresh() }
        }
    }

    private func perk(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            Text(text)
                .font(.subheadline)
        }
    }
}
