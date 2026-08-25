//
//  OnboardingView.swift
//  ForjaApp
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @State private var page = 0
    @State private var selectedAvatarID = MedievalAvatar.default.id

    var body: some View {
        ZStack {
            MedievalBackdropView()

            VStack(spacing: 24) {
                TabView(selection: $page) {
                    welcomePage.tag(0)
                    avatarPage.tag(1)
                    trialPage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                if page < 2 {
                    Button {
                        withAnimation { page += 1 }
                    } label: {
                        Text(page == 0 ? "Escolher avatar" : "Ver trial")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(ForgePrimaryButtonStyle())
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 16)
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 20) {
            Text("🔥")
                .font(.system(size: 72))
            Text("Forja")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            Text("O app de foco pra quem curte RPG e fantasia.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))
            Text("Acenda a fornalha, resista às distrações e transforme concentração em minério. Colecionáveis raros só saem de sessões de verdade.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
        }
        .padding(28)
    }

    private var avatarPage: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 16) {
                    Text("Escolha seu herói")
                        .font(.title.bold())
                    Text("Esse avatar vai caminhar na trilha semanal de foco.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(MedievalAvatar.catalog) { avatar in
                            Button {
                                selectedAvatarID = avatar.id
                            } label: {
                                VStack(spacing: 8) {
                                    Text(avatar.emoji)
                                        .font(.system(size: 40))
                                    Text(avatar.name)
                                        .font(.headline)
                                    Text(avatar.title)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.white.opacity(selectedAvatarID == avatar.id ? 0.14 : 0.06))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                .strokeBorder(
                                                    Color(hex: avatar.accentHex) ?? .orange,
                                                    lineWidth: selectedAvatarID == avatar.id ? 2 : 0
                                                )
                                        }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
                .frame(minWidth: geo.size.width)
            }
            .scrollIndicators(.visible)
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var trialPage: some View {
        VStack(spacing: 18) {
            Text("7 dias de Mestre Ferreiro")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text("Skins de bigorna, estatísticas avançadas, temas exclusivos, sessões ilimitadas e backup na nuvem.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 10) {
                trialRow("Skins de bigorna e fornalha")
                trialRow("Estatísticas avançadas e horário de pico")
                trialRow("Sem limite diário de sessões")
                trialRow("Modo tolerante estendido")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button {
                inventory.selectAvatar(MedievalAvatar.avatar(for: selectedAvatarID))
                inventory.setUsesAvatarAsProfilePhoto(true)
                inventory.startTrialIfNeeded()
            } label: {
                Text("Começar trial grátis")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(ForgePrimaryButtonStyle())

            Button("Continuar no modo livre") {
                inventory.selectAvatar(MedievalAvatar.avatar(for: selectedAvatarID))
                inventory.setUsesAvatarAsProfilePhoto(true)
                inventory.completeOnboarding()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(24)
    }

    private func trialRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            Text(text)
                .font(.subheadline)
        }
    }
}
