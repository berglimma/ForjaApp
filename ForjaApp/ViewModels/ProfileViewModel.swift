//
//  ProfileViewModel.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Combine
import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    enum AuthMode {
        case login
        case signUp
    }

    @Published var authMode: AuthMode = .login
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var dailyGoalMinutes: Double = 60
    @Published var weeklyGoalMinutes: Double = 300
    @Published var isLoading = false
    @Published var authMessage: String?
    @Published var showAuthForm = false
    @Published var profileImage: UIImage?

    private let firebaseManager = FirebaseManager.shared
    private let inventoryManager = InventoryManager.shared

    var progress: UserProgress { inventoryManager.progress }
    var currentUser: AuthUserProfile? { firebaseManager.currentUser }
    var isLoggedInWithAccount: Bool { firebaseManager.isLoggedInWithAccount }

    func onAppear() {
        dailyGoalMinutes = Double(progress.dailyGoalMinutes)
        weeklyGoalMinutes = Double(progress.weeklyGoalMinutes)
        displayName = progress.displayName
        loadProfilePhoto()
        Task { await refreshLeaderboard() }
    }

    func loadProfilePhoto() {
        profileImage = ProfileImageStore.shared.load()
    }

    func updateProfilePhoto(data: Data) {
        guard let image = UIImage(data: data) else {
            authMessage = "Não foi possível carregar a foto selecionada."
            return
        }

        ProfileImageStore.shared.save(image)
        profileImage = ProfileImageStore.shared.load()
        authMessage = "Foto de perfil atualizada."
    }

    func removeProfilePhoto() {
        ProfileImageStore.shared.delete()
        profileImage = nil
        authMessage = "Foto de perfil removida."
    }

    func refreshLeaderboard() async {
        await firebaseManager.fetchLeaderboard()
    }

    func submitAuth() async {
        authMessage = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, password.count >= 6 else {
            authMessage = "E-mail válido e senha com no mínimo 6 caracteres."
            return
        }

        if authMode == .signUp, trimmedName.isEmpty {
            authMessage = "Informe um nome de ferreiro."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            switch authMode {
            case .login:
                try await firebaseManager.signIn(email: trimmedEmail, password: password)
                authMessage = "Login realizado com sucesso!"
            case .signUp:
                try await firebaseManager.signUp(email: trimmedEmail, password: password, displayName: trimmedName)
                inventoryManager.updateDisplayName(trimmedName)
                authMessage = "Conta criada com sucesso!"
            }
            showAuthForm = false
            email = ""
            password = ""
            await refreshLeaderboard()
        } catch {
            authMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        authMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await GoogleSignInService.signIn()
            authMessage = "Login com Google realizado!"
            await refreshLeaderboard()
        } catch {
            authMessage = error.localizedDescription
        }
    }

    func signOut() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await firebaseManager.signOut()
            authMessage = "Você saiu da conta."
        } catch {
            authMessage = error.localizedDescription
        }
    }

    func saveDailyGoal() {
        inventoryManager.updateDailyGoal(minutes: Int(dailyGoalMinutes))
    }

    func saveWeeklyGoal() {
        inventoryManager.updateWeeklyGoal(minutes: Int(weeklyGoalMinutes))
    }
}
