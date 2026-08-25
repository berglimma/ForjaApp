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
    @State private var isPurchasing = false

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
                Text("Zero segundos de graça. Sair do reino apaga o fogo na hora. Distintivo de ferreiro implacável.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Segundos de graça antes da sessão falhar: \(inventory.progress.graceSeconds)s. Depois disso, o pântano cobre a brasa.")
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
                Button {
                    Task { await unlockHardcore() }
                } label: {
                    HStack(spacing: 10) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "bolt.shield.fill")
                        }
                        Text(isPurchasing ? "Abrindo a forja negra…" : "Desbloquear Hardcore")
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(HardcoreUnlockButtonStyle())
                .disabled(isPurchasing)
                .accessibilityLabel("Desbloquear Hardcore")

                Text("Sem perdão: qualquer saída apaga o fogo. Compra única — ou incluso no Mestre Ferreiro.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Toggle("Arautos do reino", isOn: Binding(
                get: { inventory.progress.notificationsEnabled },
                set: { enabled in
                    Task {
                        if enabled {
                            let granted = await NotificationScheduler.requestPermission()
                            inventory.setNotificationsEnabled(granted)
                        } else {
                            inventory.setNotificationsEnabled(false)
                        }
                    }
                }
            ))
            Text("\(inventory.progress.selectedAvatar.name) recebe chamados na alvorada, na estrada de areia, no pântano e quando a fornalha esfria.")
                .font(.caption2)
                .foregroundStyle(.secondary)
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

    private func unlockHardcore() async {
        isPurchasing = true
        defer { isPurchasing = false }

        if store.product(id: StoreProductID.hardcore) == nil {
            await store.refresh()
        }

        if let product = store.product(id: StoreProductID.hardcore) {
            _ = await store.purchase(product)
        } else {
            showPaywall = true
        }
    }
}
