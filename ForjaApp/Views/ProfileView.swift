//
//  ProfileView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @EnvironmentObject private var firebase: FirebaseManager
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    accountSection
                    statsSection
                    chartSection
                    dailyGoalSection
                    weeklyGoalSection
                    rankingSection
                }
                .padding()
            }
            .background((Color(hex: "#0D1117") ?? .black).ignoresSafeArea())
            .navigationTitle("Perfil")
            .refreshable {
                await viewModel.refreshLeaderboard()
            }
            .onAppear { viewModel.onAppear() }
            .sheet(isPresented: $viewModel.showAuthForm) {
                authSheet
            }
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ProfileAvatarView(
                    image: viewModel.profileImage,
                    placeholderSystemName: accountIconName,
                    onImageDataSelected: { data in
                        viewModel.updateProfilePhoto(data: data)
                    },
                    onRemove: {
                        viewModel.removeProfilePhoto()
                    }
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(inventory.progress.displayName)
                        .font(.subheadline.bold())
                        .lineLimit(2)

                    if viewModel.isLoggedInWithAccount {
                        if let email = viewModel.currentUser?.email {
                            Text(email)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Text(accountProviderLabel)
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                    } else {
                        Text("Conta convidado — faça login para entrar no ranking")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 4)

                if viewModel.isLoggedInWithAccount {
                    Button {
                        Task { await viewModel.signOut() }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.body)
                            .foregroundStyle(.red.opacity(0.9))
                            .padding(8)
                            .background(Color.red.opacity(0.12), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Sair da conta")
                }
            }

            if !viewModel.isLoggedInWithAccount {
                Button {
                    Task { await viewModel.signInWithGoogle() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "g.circle.fill")
                            .font(.subheadline)
                        Text("Continuar com Google")
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
                .disabled(viewModel.isLoading)

                HStack(spacing: 8) {
                    Button {
                        viewModel.authMode = .login
                        viewModel.showAuthForm = true
                    } label: {
                        Text("Entrar")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(ForgePrimaryButtonStyle())

                    Button {
                        viewModel.authMode = .signUp
                        viewModel.showAuthForm = true
                    } label: {
                        Text("Cadastrar")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(ForgeSecondaryButtonStyle())
                }
            }

            if let message = viewModel.authMessage {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var accountIconName: String {
        switch viewModel.currentUser?.provider {
        case .google: return "g.circle.fill"
        case .email: return "envelope.circle.fill"
        default: return "person.crop.circle.fill"
        }
    }

    private var accountProviderLabel: String {
        switch viewModel.currentUser?.provider {
        case .google: return "Conectado via Google"
        case .email: return "Conectado via e-mail"
        default: return "Conta ativa"
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estatísticas")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ProfileStatTile(
                    title: "Tempo de foco",
                    value: UserProgress.formatDuration(seconds: inventory.progress.totalFocusSeconds),
                    icon: "clock.fill"
                )
                ProfileStatTile(
                    title: "Não cumprido",
                    value: UserProgress.formatDuration(seconds: inventory.progress.unfulfilledFocusSeconds),
                    icon: "xmark.seal.fill"
                )
                ProfileStatTile(
                    title: "Forjas OK",
                    value: "\(inventory.progress.successfulSessions)",
                    icon: "checkmark.seal.fill"
                )
                ProfileStatTile(
                    title: "Falhas",
                    value: "\(inventory.progress.failedSessions)",
                    icon: "exclamationmark.triangle.fill"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var chartSection: some View {
        FocusTimeChartView(segments: inventory.progress.chartSegments)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var dailyGoalSection: some View {
        goalCard(
            title: "Meta diária",
            progressText: "\(UserProgress.formatDuration(seconds: inventory.progress.dailyFocusSeconds)) de \(inventory.progress.dailyGoalMinutes) min",
            progress: inventory.progress.dailyGoalProgress,
            isMet: inventory.progress.isDailyGoalMet,
            sliderValue: $viewModel.dailyGoalMinutes,
            sliderRange: 15...240,
            sliderLabel: "Objetivo: \(Int(viewModel.dailyGoalMinutes)) min/dia",
            saveAction: viewModel.saveDailyGoal
        )
    }

    private var weeklyGoalSection: some View {
        goalCard(
            title: "Meta semanal",
            progressText: "\(UserProgress.formatDuration(seconds: inventory.progress.weeklyFocusSeconds)) de \(inventory.progress.weeklyGoalMinutes) min",
            progress: inventory.progress.weeklyGoalProgress,
            isMet: inventory.progress.isWeeklyGoalMet,
            sliderValue: $viewModel.weeklyGoalMinutes,
            sliderRange: 30...600,
            sliderLabel: "Objetivo: \(Int(viewModel.weeklyGoalMinutes)) min/semana",
            saveAction: viewModel.saveWeeklyGoal
        )
    }

    private func goalCard(
        title: String,
        progressText: String,
        progress: Double,
        isMet: Bool,
        sliderValue: Binding<Double>,
        sliderRange: ClosedRange<Double>,
        sliderLabel: String,
        saveAction: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if isMet {
                    Label("Concluída", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
                }
            }

            Text(progressText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
                .tint(Color(hex: "#F6AD55") ?? .orange)

            Text(sliderLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            Slider(value: sliderValue, in: sliderRange, step: 15)
                .tint(Color(hex: "#F6AD55") ?? .orange)

            Button(action: saveAction) {
                Text("Salvar \(title.lowercased())")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(ForgePrimaryButtonStyle())
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ranking global")
                    .font(.headline)
                Spacer()
                Button {
                    Task { await viewModel.refreshLeaderboard() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }

            if firebase.leaderboard.isEmpty {
                Text("Faça login, complete forjas para aparecer no ranking.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(firebase.leaderboard) { entry in
                    LeaderboardRow(
                        entry: entry,
                        isCurrentUser: entry.id == viewModel.currentUser?.uid
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var authSheet: some View {
        NavigationStack {
            Form {
                Picker("Modo", selection: $viewModel.authMode) {
                    Text("Entrar").tag(ProfileViewModel.AuthMode.login)
                    Text("Cadastrar").tag(ProfileViewModel.AuthMode.signUp)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)

                if viewModel.authMode == .signUp {
                    TextField("Nome de ferreiro", text: $viewModel.displayName)
                        .textContentType(.name)
                }

                TextField("E-mail", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)

                SecureField("Senha (mín. 6)", text: $viewModel.password)
                    .textContentType(viewModel.authMode == .signUp ? .newPassword : .password)

                if let message = viewModel.authMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await viewModel.submitAuth() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(viewModel.authMode == .login ? "Entrar" : "Criar conta")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isLoading)
            }
            .navigationTitle(viewModel.authMode == .login ? "Entrar" : "Cadastrar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { viewModel.showAuthForm = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct ProfileStatTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
            Text(value)
                .font(.headline.bold())
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(entry.rank)")
                .font(.headline.bold())
                .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                .frame(width: 36, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.subheadline.bold())
                Text("\(entry.formattedFocusTime) · \(entry.successfulSessions) forjas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCurrentUser {
                Text("Você")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#C05621")?.opacity(0.4) ?? .orange.opacity(0.4), in: Capsule())
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProfileView()
        .environmentObject(InventoryManager.shared)
        .environmentObject(FirebaseManager.shared)
}
