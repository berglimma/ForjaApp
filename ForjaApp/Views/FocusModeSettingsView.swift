//
//  FocusModeSettingsView.swift
//  ForjaApp
//

import SwiftUI

struct FocusModeSettingsView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @StateObject private var entitlements = EntitlementStore.shared
    @StateObject private var store = StoreManager.shared
    @State private var showPaywall = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Disciplina da forja")
                .font(.headline)

            Picker("Modo", selection: hardcoreBinding) {
                Text("Tolerante").tag(false)
                Text("Hardcore").tag(true)
            }
            .pickerStyle(.segmented)

            if inventory.progress.isHardcoreEnabled {
                Text("Zero segundos de graça. Sair do app apaga o fogo na hora. Distintivo de ferreiro implacável.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Segundos de graça antes da sessão falhar: \(inventory.progress.graceSeconds)s")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Slider(
                    value: graceBinding,
                    in: 0...Double(entitlements.maxGraceSeconds),
                    step: 1
                )
                .tint(Color(hex: "#F6AD55") ?? .orange)

                if !entitlements.canUseExtraGrace {
                    Text("Até \(EntitlementLimits.freeMaxGraceSeconds)s no plano livre. Assine para até \(EntitlementLimits.subscriberMaxGraceSeconds)s.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if !entitlements.canEnableHardcore && !inventory.progress.isHardcoreEnabled {
                Button("Desbloquear Hardcore") {
                    Task {
                        if let product = store.product(id: StoreProductID.hardcore) {
                            _ = await store.purchase(product)
                        } else {
                            showPaywall = true
                        }
                    }
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(inventory)
        }
    }

    private var hardcoreBinding: Binding<Bool> {
        Binding(
            get: { inventory.progress.isHardcoreEnabled },
            set: { enabled in
                if enabled && !entitlements.canEnableHardcore {
                    showPaywall = true
                    return
                }
                inventory.setHardcoreEnabled(enabled)
            }
        )
    }

    private var graceBinding: Binding<Double> {
        Binding(
            get: { Double(inventory.progress.graceSeconds) },
            set: { inventory.updateGraceSeconds(Int($0)) }
        )
    }
}
