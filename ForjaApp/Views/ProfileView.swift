//
//  ProfileView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @EnvironmentObject private var firebase: FirebaseManager
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var entitlements = EntitlementStore.shared
    @State private var shareImage: IdentifiableImage?
    @State private var shareFile: IdentifiableURL?
    @State private var shareError: String?
    @State private var showAvatarPicker = false
    @State private var showAvatarStudio = false
    @State private var showDeleteAccount = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    accountSection
                    avatarStudioCard
                    socialShareCard
                    subscriptionBanner
                    FocusModeSettingsView()
                    statsSection
                    if entitlements.canUseAdvancedStats {
                        advancedStatsSection
                    } else {
                        lockedStatsSection
                    }
                    chartSection
                    dailyGoalSection
                    weeklyGoalSection
                    rankingSection
                }
                .padding()
            }
            .background {
                MedievalBackdropView()
            }
            .navigationTitle("Perfil")
            .refreshable {
                await viewModel.refreshLeaderboard()
            }
            .onAppear { viewModel.onAppear() }
            .sheet(isPresented: $viewModel.showAuthForm) {
                authSheet
            }
            .sheet(item: $shareImage) { wrapper in
                ShareSheet(items: [wrapper.image])
            }
            .sheet(item: $shareFile) { wrapper in
                ShareSheet(items: [wrapper.url])
            }
            .alert("Não foi possível postar", isPresented: Binding(
                get: { shareError != nil },
                set: { if !$0 { shareError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(shareError ?? "")
            }
            .confirmationDialog(
                "Excluir conta?",
                isPresented: $showDeleteAccount,
                titleVisibility: .visible
            ) {
                Button("Excluir conta e dados", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Apaga o login, o ranking na nuvem e o progresso salvo nesta conta. Não dá para desfazer. Compras da App Store continuam na sua conta Apple — use Restaurar compras se entrar de novo.")
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerSheet(selectedID: inventory.progress.selectedAvatarID) { avatar in
                    inventory.selectAvatar(avatar)
                    showAvatarPicker = false
                }
                .environmentObject(inventory)
            }
            .sheet(isPresented: $showAvatarStudio) {
                AvatarStudioView(look: inventory.progress.usesCustomAvatar
                    ? inventory.progress.customAvatarLook
                    : AvatarLook.seeded(from: inventory.progress.selectedAvatar)
                )
                .environmentObject(inventory)
            }
        }
    }

    private var avatarStudioCard: some View {
        Button {
            showAvatarStudio = true
        } label: {
            HStack(spacing: 14) {
                AssembledAvatarView(
                    look: inventory.progress.usesCustomAvatar
                        ? inventory.progress.customAvatarLook
                        : AvatarLook.seeded(from: inventory.progress.selectedAvatar),
                    style: .bust
                )
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ateliê do herói")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Crie o corpo e as vestimentas realistas: pele, cabelo, gibão, malha, placas e capa.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var socialShareCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Card para redes")
                .font(.headline)
            Text("Pergaminho medieval com tempo de foco, barras, forjas e a crônica do dia — uma frase nova para cada dia do ano.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProfileSocialPreview(
                displayName: inventory.progress.displayName,
                avatarImageName: inventory.progress.selectedAvatar.imageName,
                photo: inventory.progress.usesAvatarAsProfilePhoto ? nil : viewModel.profileImage,
                lifetimeBars: inventory.progress.lifetimeBars,
                successfulForges: inventory.progress.successfulSessions,
                streak: inventory.progress.currentStreak,
                focusText: UserProgress.formatDuration(seconds: inventory.progress.totalFocusSeconds),
                challengeName: OreChallengeLadder.active(lifetimeBars: inventory.progress.lifetimeBars).name,
                look: inventory.progress.customAvatarLook,
                usesCustomLook: inventory.progress.usesCustomAvatar
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
                shareProfileCard(to: .system)
            } label: {
                Label("Compartilhar", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(ForgePrimaryButtonStyle())

            HStack(spacing: 10) {
                Button {
                    shareProfileCard(to: .instagramStories)
                } label: {
                    Label("Stories", systemImage: "camera.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgeSecondaryButtonStyle())

                Button {
                    shareProfileCard(to: .whatsAppStatus)
                } label: {
                    Label("Status", systemImage: "message.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(ForgeSecondaryButtonStyle())
            }

            Text("Stories abre o Instagram. Status abre o WhatsApp — escolha Status na lista.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func shareProfileCard(to destination: SocialStoryShare.Destination) {
        guard let image = AchievementShareRenderer.renderProfileCard(
            displayName: inventory.progress.displayName,
            avatarImageName: inventory.progress.selectedAvatar.imageName,
            photo: inventory.progress.usesAvatarAsProfilePhoto ? nil : viewModel.profileImage,
            lifetimeBars: inventory.progress.lifetimeBars,
            successfulForges: inventory.progress.successfulSessions,
            currentStreak: inventory.progress.currentStreak,
            focusSeconds: inventory.progress.totalFocusSeconds,
            challengeName: OreChallengeLadder.active(lifetimeBars: inventory.progress.lifetimeBars).name,
            look: inventory.progress.customAvatarLook,
            usesCustomLook: inventory.progress.usesCustomAvatar
        ) else {
            shareError = SocialStoryShare.ShareError.imageFailed.localizedDescription
            return
        }

        switch destination {
        case .system:
            shareImage = IdentifiableImage(image: image)
        case .instagramStories:
            do {
                try SocialStoryShare.shareToInstagramStories(image)
            } catch {
                shareError = error.localizedDescription
            }
        case .whatsAppStatus:
            guard SocialStoryShare.canOpenWhatsApp else {
                shareError = SocialStoryShare.ShareError.whatsAppMissing.localizedDescription
                return
            }
            do {
                let url = try SocialStoryShare.temporaryJPEGURL(for: image)
                shareFile = IdentifiableURL(url: url)
            } catch {
                shareError = error.localizedDescription
            }
        }
    }

    private var subscriptionBanner: some View {
        SubscriptionBanner()
    }

    private var advancedStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Estatísticas avançadas")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ProfileStatTile(
                    title: "Taxa de sucesso",
                    value: "\(Int(inventory.progress.successRate * 100))%",
                    icon: "percent"
                )
                ProfileStatTile(
                    title: "Horário de pico",
                    value: String(format: "%02dh", inventory.progress.peakHour),
                    icon: "clock.badge.checkmark"
                )
                ProfileStatTile(
                    title: "Melhor dia",
                    value: UserProgress.weekdayFullLabel(index: inventory.progress.peakWeekdayIndex),
                    icon: "calendar"
                )
                ProfileStatTile(
                    title: "Barras no ofício",
                    value: "\(inventory.progress.lifetimeBars)",
                    icon: "hammer.fill"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var lockedStatsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estatísticas avançadas")
                .font(.headline)
            Text("Horário de pico, taxa de sucesso e melhor dia da semana ficam no Mestre Ferreiro.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ProfileAvatarView(
                    image: viewModel.profileImage,
                    placeholderSystemName: accountIconName,
                    avatarImageName: inventory.progress.selectedAvatar.imageName,
                    usesAvatar: inventory.progress.usesAvatarAsProfilePhoto,
                    look: inventory.progress.customAvatarLook,
                    usesCustomLook: inventory.progress.usesCustomAvatar,
                    onImageDataSelected: { data in
                        viewModel.updateProfilePhoto(data: data)
                    },
                    onUseAvatar: {
                        viewModel.useAvatarAsProfilePhoto()
                    },
                    onRemove: {
                        viewModel.removeProfilePhoto()
                    }
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(inventory.progress.displayName)
                        .font(.subheadline.bold())
                        .lineLimit(2)

                    Button {
                        showAvatarPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            MedievalAvatarFaceView(
                                avatar: inventory.progress.selectedAvatar,
                                size: 22,
                                lineWidth: 1,
                                look: inventory.progress.customAvatarLook,
                                usesCustomLook: inventory.progress.usesCustomAvatar
                            )
                            Text(inventory.progress.selectedAvatar.name)
                                .font(.caption.bold())
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(Color(hex: inventory.progress.selectedAvatar.accentHex) ?? .orange)
                    }
                    .buttonStyle(.plain)

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

            if viewModel.isLoggedInWithAccount {
                Button("Excluir conta") {
                    showDeleteAccount = true
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red.opacity(0.9))
                .disabled(viewModel.isLoading)
            }

            if !viewModel.isLoggedInWithAccount {
                SignInWithAppleButton(.signIn) { request in
                    AppleSignInService.prepare(request)
                } onCompletion: { result in
                    Task { await viewModel.signInWithApple(result) }
                }
                .signInWithAppleButtonStyle(.white)
                .frame(height: 44)
                .disabled(viewModel.isLoading)
                .accessibilityLabel("Entrar com Apple")

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
        case .apple: return "apple.logo"
        case .email: return "envelope.circle.fill"
        default: return "person.crop.circle.fill"
        }
    }

    private var accountProviderLabel: String {
        switch viewModel.currentUser?.provider {
        case .google: return "Conectado via Google"
        case .apple: return "Conectado com Apple"
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

struct SubscriptionBanner: View {
    @StateObject private var entitlements = EntitlementStore.shared
    @State private var showPaywall = false
    @EnvironmentObject private var inventory: InventoryManager

    var body: some View {
        Button { showPaywall = true } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mestre Ferreiro")
                        .font(.headline)
                    if entitlements.isStoreKitSubscribed {
                        Text("Assinatura ativa")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else if entitlements.isPremium {
                        Text("Voucher ativo · conteúdo completo")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else {
                        Text("\(StoreProductID.monthlyListPriceBRL)/mês · \(StoreProductID.yearlyListPriceBRL)/ano · \(EntitlementLimits.trialDurationDays) dias grátis na App Store")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .foregroundStyle(Color(hex: "#F6E05E") ?? .yellow)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPaywall) {
            SubscriptionPaywallView()
                .environmentObject(inventory)
        }
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
