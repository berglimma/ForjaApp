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
    @State private var voucherCode = ""
    @State private var voucherMessage: String?
    @State private var isRedeemingVoucher = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("👑")
                        .font(.system(size: 56))
                    Text("Mestre Ferreiro")
                        .font(.largeTitle.bold())
                    Text("Assinatura auto-renovável: \(StoreProductID.monthlyListPriceBRL)/mês ou \(StoreProductID.yearlyListPriceBRL)/ano. Os \(EntitlementLimits.trialDurationDays) dias grátis são a oferta introdutória da App Store, na primeira assinatura.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if entitlements.isStoreKitSubscribed {
                        Text("Assinatura ativa")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    } else if entitlements.isPremium {
                        Text("Voucher ativo · conteúdo completo")
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
                            VStack(spacing: 4) {
                                Text("Anual · \(yearly.displayPrice)")
                                    .font(.headline)
                                Text("Melhor valor · lista \(StoreProductID.yearlyListPriceBRL)/ano")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(ForgePrimaryButtonStyle())
                    } else {
                        pricePlaceholder(
                            title: "Anual · \(StoreProductID.yearlyListPriceBRL)",
                            subtitle: "Publique o IAP com.forja.subscription.yearly na App Store"
                        )
                    }

                    if let monthly = store.monthlyProduct {
                        Button {
                            Task { _ = await store.purchase(monthly) }
                        } label: {
                            VStack(spacing: 4) {
                                Text("Mensal · \(monthly.displayPrice)")
                                    .font(.headline)
                                Text("Lista \(StoreProductID.monthlyListPriceBRL)/mês")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(ForgeSecondaryButtonStyle())
                    } else {
                        pricePlaceholder(
                            title: "Mensal · \(StoreProductID.monthlyListPriceBRL)",
                            subtitle: "Publique o IAP com.forja.subscription.monthly na App Store"
                        )
                    }

                    Button("Restaurar compras") {
                        Task { await store.restore() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    voucherRedeemCard

                    Text("O pagamento é cobrado na conta Apple. A assinatura se renova automaticamente, salvo cancelamento até 24 horas antes do fim do período. Gerencie ou cancele em Ajustes → Assinaturas.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        NavigationLink("Política de privacidade") {
                            PrivacyPolicyView()
                        }
                        Link("Termos de uso", destination: ForjaLegal.appleStandardEULA)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)

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

    private func pricePlaceholder(title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func perk(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            Text(text)
                .font(.subheadline)
        }
    }

    private var voucherRedeemCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tenho um voucher")
                .font(.headline)
            Text("Código de acesso completo: assinatura, skins, packs, hardcore e colecionáveis.")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("FORJA-XXXX-XXXX", text: $voucherCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.body.monospaced())
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Button {
                Task { await redeemVoucher() }
            } label: {
                Text(isRedeemingVoucher ? "Resgatando…" : "Resgatar")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(ForgeSecondaryButtonStyle())
            .disabled(isRedeemingVoucher || voucherCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let voucherMessage {
                Text(voucherMessage)
                    .font(.caption)
                    .foregroundStyle(entitlements.isPremium ? .green : .red)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func redeemVoucher() async {
        isRedeemingVoucher = true
        defer { isRedeemingVoucher = false }
        do {
            try await inventory.redeemFullAccessVoucher(voucherCode)
            voucherMessage = "Voucher resgatado. Todo o conteúdo está liberado."
            voucherCode = ""
        } catch {
            voucherMessage = error.localizedDescription
        }
    }
}
