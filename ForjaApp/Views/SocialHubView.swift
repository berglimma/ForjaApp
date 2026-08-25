//
//  SocialHubView.swift
//  ForjaApp
//

import SwiftUI

struct SocialHubView: View {
    @EnvironmentObject private var firebase: FirebaseManager
    @StateObject private var social = SocialService.shared
    @State private var guildName = ""
    @State private var guildCode = ""
    @State private var challengeCode = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if !firebase.isLoggedInWithAccount {
                        loginPrompt
                    } else {
                        guildSection
                        challengeSection
                    }
                }
                .padding()
            }
            .background {
                MedievalBackdropView()
            }
            .navigationTitle("Guilda")
            .task { await social.refresh() }
            .refreshable { await social.refresh() }
        }
    }

    private var loginPrompt: some View {
        VStack(spacing: 12) {
            Text("🛡️")
                .font(.system(size: 48))
            Text("Entre com uma conta para criar guildas e desafios entre amigos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var guildSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Guilda de foco")
                .font(.headline)
            Text("Até 8 ferreiros competindo pelo total de barras da semana.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let guild = social.currentGuild {
                Text(guild.name)
                    .font(.title3.bold())
                Text("Código: \(guild.joinCode)")
                    .font(.caption.monospaced())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)

                ForEach(guild.rankedMembers) { member in
                    HStack {
                        Text("#\(member.rank)")
                            .font(.headline)
                            .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                            .frame(width: 36, alignment: .leading)
                        Text(member.displayName)
                        Spacer()
                        Text("\(member.weeklyBars) 🧱")
                            .font(.subheadline.bold())
                    }
                    .padding(.vertical, 4)
                }
            } else {
                TextField("Nome da guilda", text: $guildName)
                    .textFieldStyle(.roundedBorder)
                Button("Criar guilda") {
                    Task { await social.createGuild(name: guildName) }
                }
                .buttonStyle(ForgePrimaryButtonStyle())
                .disabled(social.isLoading)

                TextField("Código para entrar", text: $guildCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                Button("Entrar na guilda") {
                    Task { await social.joinGuild(code: guildCode) }
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
                .disabled(social.isLoading)
            }

            if let message = social.message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Desafio entre amigos")
                .font(.headline)
            Text("Quem foca mais essa semana?")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let challenge = social.currentChallenge {
                Text("Código: \(challenge.joinCode)")
                    .font(.caption.monospaced())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)

                challengeRow(name: challenge.hostName, seconds: challenge.hostFocusSeconds)
                if let opponentName = challenge.opponentName {
                    challengeRow(name: opponentName, seconds: challenge.opponentFocusSeconds)
                } else {
                    Text("Aguardando oponente…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("Criar desafio") {
                    Task { await social.createChallenge() }
                }
                .buttonStyle(ForgePrimaryButtonStyle())
                .disabled(social.isLoading)

                TextField("Código do desafio", text: $challengeCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                Button("Aceitar desafio") {
                    Task { await social.joinChallenge(code: challengeCode) }
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
                .disabled(social.isLoading)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func challengeRow(name: String, seconds: Int) -> some View {
        HStack {
            Text(name)
                .font(.subheadline.bold())
            Spacer()
            Text(UserProgress.formatDuration(seconds: seconds))
                .font(.subheadline)
        }
    }
}
