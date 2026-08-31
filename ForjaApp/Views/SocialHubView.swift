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
    @State private var confirmLeaveGuild = false
    @State private var confirmLeaveChallenge = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
        VStack(spacing: 10) {
            Text("🛡️")
                .font(.title)
            Text("Entre com uma conta para criar guildas e desafios entre amigos.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
                guildHeader(guild)

                ForEach(guild.rankedMembers) { member in
                    socialRow(
                        rank: member.rank,
                        name: member.displayName,
                        detail: "\(member.weeklyBars) barras",
                        isCurrentUser: member.id == firebase.currentUser?.uid
                    )
                }

                Button {
                    confirmLeaveGuild = true
                } label: {
                    Text("Sair da guilda")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
                .disabled(social.isLoading)
                .confirmationDialog(
                    "Sair da guilda?",
                    isPresented: $confirmLeaveGuild,
                    titleVisibility: .visible
                ) {
                    Button("Sair da guilda", role: .destructive) {
                        Task { await social.leaveGuild() }
                    }
                    Button("Cancelar", role: .cancel) {}
                } message: {
                    Text("Você deixa o ranking semanal desta guilda. Pode entrar de novo com o código.")
                }
            } else {
                studioField("Nome da guilda", text: $guildName)
                Button {
                    Task { await social.createGuild(name: guildName) }
                } label: {
                    Text("Criar guilda")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgePrimaryButtonStyle())
                .disabled(social.isLoading)

                studioField("Código para entrar", text: $guildCode)
                    .textInputAutocapitalization(.characters)
                Button {
                    Task { await social.joinGuild(code: guildCode) }
                } label: {
                    Text("Entrar na guilda")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
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

                socialRow(
                    rank: 1,
                    name: challenge.hostName,
                    detail: UserProgress.formatDuration(seconds: challenge.hostFocusSeconds),
                    isCurrentUser: challenge.hostID == firebase.currentUser?.uid
                )
                if let opponentName = challenge.opponentName {
                    socialRow(
                        rank: 2,
                        name: opponentName,
                        detail: UserProgress.formatDuration(seconds: challenge.opponentFocusSeconds),
                        isCurrentUser: challenge.opponentID == firebase.currentUser?.uid
                    )
                } else {
                    Text("Aguardando oponente…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    confirmLeaveChallenge = true
                } label: {
                    Text("Sair do desafio")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
                .disabled(social.isLoading)
                .confirmationDialog(
                    "Sair do desafio?",
                    isPresented: $confirmLeaveChallenge,
                    titleVisibility: .visible
                ) {
                    Button("Sair do desafio", role: .destructive) {
                        Task { await social.leaveChallenge() }
                    }
                    Button("Cancelar", role: .cancel) {}
                } message: {
                    Text("O desafio desta semana acaba para você. Se você criou o desafio, o outro ferreiro também sai.")
                }
            } else {
                Button {
                    Task { await social.createChallenge() }
                } label: {
                    Text("Criar desafio")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgePrimaryButtonStyle())
                .disabled(social.isLoading)

                studioField("Código do desafio", text: $challengeCode)
                    .textInputAutocapitalization(.characters)
                Button {
                    Task { await social.joinChallenge(code: challengeCode) }
                } label: {
                    Text("Aceitar desafio")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
                .disabled(social.isLoading)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func guildHeader(_ guild: Guild) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.fill")
                .font(.subheadline)
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(guild.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("Código: \(guild.joinCode)")
                    .font(.caption.monospaced())
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            }
            Spacer(minLength: 8)
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func socialRow(rank: Int, name: String, detail: String, isCurrentUser: Bool) -> some View {
        HStack(spacing: 10) {
            Text("#\(rank)")
                .font(.caption.bold())
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                .frame(width: 28, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if isCurrentUser {
                Text("Você")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#C05621")?.opacity(0.4) ?? .orange.opacity(0.4), in: Capsule())
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func studioField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.subheadline)
            .padding(12)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
