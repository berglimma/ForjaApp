//
//  FirebaseManager.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Foundation
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

@MainActor
final class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    @Published private(set) var isConfigured = false
    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncError: String?
    @Published private(set) var currentUser: AuthUserProfile?
    @Published private(set) var leaderboard: [LeaderboardEntry] = []

    #if canImport(FirebaseAuth)
    private var authListener: AuthStateDidChangeListenerHandle?
    #endif

    private init() {
        isConfigured = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        #if canImport(FirebaseAuth)
        if isConfigured {
            authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
                Task { @MainActor in
                    self?.updateCurrentUser(from: user)
                }
            }
            Task { await bootstrap() }
        }
        #endif
    }

    var isLoggedInWithAccount: Bool {
        guard let currentUser else { return false }
        return !currentUser.isAnonymous
    }

    func bootstrap() async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard isConfigured else { return }

        do {
            if Auth.auth().currentUser == nil {
                _ = try await Auth.auth().signInAnonymously()
            }
            updateCurrentUser(from: Auth.auth().currentUser)
            await fetchAndMergeProgress()
        } catch {
            lastSyncError = error.localizedDescription
        }
        #endif
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        #if canImport(FirebaseAuth)
        guard isConfigured else { throw AuthFlowError.firebaseNotConfigured }

        let localProgress = InventoryManager.shared.progress
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        if let user = Auth.auth().currentUser, user.isAnonymous {
            let result = try await user.link(with: credential)
            try await updateAuthDisplayName(result.user, name: displayName)
        } else {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await updateAuthDisplayName(result.user, name: displayName)
        }

        var progress = localProgress
        progress.displayName = displayName
        InventoryManager.shared.applyRemoteProgress(progress)
        await syncProgress(progress)
        updateCurrentUser(from: Auth.auth().currentUser)
        #else
        throw AuthFlowError.firebaseNotConfigured
        #endif
    }

    func signIn(email: String, password: String) async throws {
        #if canImport(FirebaseAuth)
        guard isConfigured else { throw AuthFlowError.firebaseNotConfigured }

        _ = try await Auth.auth().signIn(withEmail: email, password: password)
        updateCurrentUser(from: Auth.auth().currentUser)
        await fetchAndMergeProgress()
        #else
        throw AuthFlowError.firebaseNotConfigured
        #endif
    }

    func signOut() async throws {
        #if canImport(FirebaseAuth)
        guard isConfigured else { throw AuthFlowError.firebaseNotConfigured }

        GoogleSignInService.signOutIfNeeded()
        try Auth.auth().signOut()
        _ = try await Auth.auth().signInAnonymously()
        updateCurrentUser(from: Auth.auth().currentUser)
        #else
        throw AuthFlowError.firebaseNotConfigured
        #endif
    }

    func deleteAccount() async throws {
        #if canImport(FirebaseAuth)
        guard isConfigured else { throw AuthFlowError.firebaseNotConfigured }
        guard let user = Auth.auth().currentUser, !user.isAnonymous else {
            throw AuthFlowError.notLoggedIn
        }

        let uid = user.uid
        #if canImport(FirebaseFirestore)
        try await Firestore.firestore().collection("users").document(uid).delete()
        #endif

        GoogleSignInService.signOutIfNeeded()
        do {
            try await user.delete()
        } catch {
            let nsError = error as NSError
            if nsError.domain == AuthErrorDomain, nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw AuthFlowError.requiresRecentLogin
            }
            throw error
        }

        InventoryManager.shared.clearAccountData()
        _ = try await Auth.auth().signInAnonymously()
        updateCurrentUser(from: Auth.auth().currentUser)
        #else
        throw AuthFlowError.firebaseNotConfigured
        #endif
    }

    func syncProgressAfterAuth() async {
        let progress = InventoryManager.shared.progress
        await syncProgress(progress)
        await fetchAndMergeProgress()
    }

    func fetchLeaderboard() async {
        #if canImport(FirebaseFirestore)
        guard isConfigured else { return }

        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("users")
                .order(by: "totalFocusSeconds", descending: true)
                .limit(to: 20)
                .getDocuments()

            leaderboard = snapshot.documents.enumerated().compactMap { index, doc in
                let data = doc.data()
                let name = data["displayName"] as? String ?? "Ferreiro"
                let focus = data["totalFocusSeconds"] as? Int ?? 0
                let sessions = data["successfulSessions"] as? Int ?? 0
                return LeaderboardEntry(
                    id: doc.documentID,
                    displayName: name,
                    totalFocusSeconds: focus,
                    successfulSessions: sessions,
                    rank: index + 1
                )
            }
            lastSyncError = nil
        } catch {
            lastSyncError = error.localizedDescription
        }
        #endif
    }

    func syncProgress(_ progress: UserProgress) async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard isConfigured, let uid = Auth.auth().currentUser?.uid else { return }

        isSyncing = true
        defer { isSyncing = false }

        let db = Firestore.firestore()
        var data: [String: Any] = [
            "displayName": progress.displayName,
            "forgedBars": progress.forgedBars,
            "totalSessions": progress.totalSessions,
            "successfulSessions": progress.successfulSessions,
            "failedSessions": progress.failedSessions,
            "totalFocusSeconds": progress.totalFocusSeconds,
            "unfulfilledFocusSeconds": progress.unfulfilledFocusSeconds,
            "currentStreak": progress.currentStreak,
            "bestStreak": progress.bestStreak,
            "dailyGoalMinutes": progress.dailyGoalMinutes,
            "dailyFocusSeconds": progress.dailyFocusSeconds,
            "dayOfYear": progress.dayOfYear,
            "dayCalendarYear": progress.dayCalendarYear,
            "weeklyGoalMinutes": progress.weeklyGoalMinutes,
            "weeklyFocusSeconds": progress.weeklyFocusSeconds,
            "weekOfYear": progress.weekOfYear,
            "calendarYear": progress.calendarYear,
            "gems": progress.gems,
            "lifetimeBars": progress.lifetimeBars,
            "weeklyBars": progress.weeklyBars,
            "sessionsToday": progress.sessionsToday,
            "graceSeconds": progress.graceSeconds,
            "isHardcoreEnabled": progress.isHardcoreEnabled,
            "selectedAvatarID": progress.selectedAvatarID,
            "equippedAnvilSkinID": progress.equippedAnvilSkinID,
            "equippedFurnaceSkinID": progress.equippedFurnaceSkinID,
            "equippedShopThemeID": progress.equippedShopThemeID,
            "ownedCosmeticIDs": progress.ownedCosmeticIDs,
            "weekdayFocusSeconds": progress.weekdayFocusSeconds,
            "hourlySessionCounts": progress.hourlySessionCounts,
            "onboardingCompleted": progress.onboardingCompleted,
            "hasUnlockedHardcore": progress.hasUnlockedHardcore,
            "notificationsEnabled": progress.notificationsEnabled,
            "usesAvatarAsProfilePhoto": progress.usesAvatarAsProfilePhoto,
            "ownedCollectibles": progress.ownedCollectibles.map {
                [
                    "id": $0.id,
                    "itemID": $0.itemID,
                    "acquiredAt": Timestamp(date: $0.acquiredAt)
                ]
            },
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let trialStartedAt = progress.trialStartedAt {
            data["trialStartedAt"] = Timestamp(date: trialStartedAt)
        }

        do {
            try await db.collection("users").document(uid).setData(data, merge: true)
            lastSyncError = nil
        } catch {
            lastSyncError = error.localizedDescription
        }
        #endif
    }

    private func fetchAndMergeProgress() async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard isConfigured, let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            guard snapshot.exists, let data = snapshot.data() else { return }

            let remote = parseProgress(from: data)
            let local = InventoryManager.shared.progress
            let merged = merge(local: local, remote: remote)
            InventoryManager.shared.applyRemoteProgress(merged)
        } catch {
            lastSyncError = error.localizedDescription
        }
        #endif
    }

    #if canImport(FirebaseAuth)
    private func updateAuthDisplayName(_ user: User, name: String) async throws {
        let change = user.createProfileChangeRequest()
        change.displayName = name
        try await change.commitChanges()
    }

    private func updateCurrentUser(from user: User?) {
        guard let user else {
            currentUser = nil
            return
        }
        currentUser = AuthUserProfile(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName ?? InventoryManager.shared.progress.displayName,
            isAnonymous: user.isAnonymous,
            provider: authProvider(for: user)
        )
    }

    private func authProvider(for user: User) -> AuthUserProfile.AuthProvider {
        if user.isAnonymous { return .anonymous }
        if user.providerData.contains(where: { $0.providerID == "google.com" }) {
            return .google
        }
        if user.providerData.contains(where: { $0.providerID == "apple.com" }) {
            return .apple
        }
        return .email
    }
    #endif

    #if canImport(FirebaseFirestore)
    private func parseProgress(from data: [String: Any]) -> UserProgress {
        let collectiblesData = data["ownedCollectibles"] as? [[String: Any]] ?? []
        let collectibles = collectiblesData.compactMap { entry -> OwnedCollectible? in
            guard
                let id = entry["id"] as? String,
                let itemID = entry["itemID"] as? String
            else { return nil }

            let date: Date
            if let timestamp = entry["acquiredAt"] as? Timestamp {
                date = timestamp.dateValue()
            } else {
                date = Date()
            }
            return OwnedCollectible(id: id, itemID: itemID, acquiredAt: date)
        }

        let trialStartedAt: Date?
        if let timestamp = data["trialStartedAt"] as? Timestamp {
            trialStartedAt = timestamp.dateValue()
        } else {
            trialStartedAt = nil
        }

        return UserProgress(
            forgedBars: data["forgedBars"] as? Int ?? 0,
            ownedCollectibles: collectibles,
            totalSessions: data["totalSessions"] as? Int ?? 0,
            successfulSessions: data["successfulSessions"] as? Int ?? 0,
            failedSessions: data["failedSessions"] as? Int ?? 0,
            totalFocusSeconds: data["totalFocusSeconds"] as? Int ?? 0,
            unfulfilledFocusSeconds: data["unfulfilledFocusSeconds"] as? Int ?? 0,
            currentStreak: data["currentStreak"] as? Int ?? 0,
            bestStreak: data["bestStreak"] as? Int ?? 0,
            displayName: data["displayName"] as? String ?? "Ferreiro",
            dailyGoalMinutes: data["dailyGoalMinutes"] as? Int ?? 60,
            dailyFocusSeconds: data["dailyFocusSeconds"] as? Int ?? 0,
            dayOfYear: data["dayOfYear"] as? Int ?? UserProgress.empty.dayOfYear,
            dayCalendarYear: data["dayCalendarYear"] as? Int ?? UserProgress.empty.dayCalendarYear,
            weeklyGoalMinutes: data["weeklyGoalMinutes"] as? Int ?? 300,
            weeklyFocusSeconds: data["weeklyFocusSeconds"] as? Int ?? 0,
            weekOfYear: data["weekOfYear"] as? Int ?? UserProgress.empty.weekOfYear,
            calendarYear: data["calendarYear"] as? Int ?? UserProgress.empty.calendarYear,
            gems: data["gems"] as? Int ?? 0,
            lifetimeBars: data["lifetimeBars"] as? Int ?? (data["forgedBars"] as? Int ?? 0),
            weeklyBars: data["weeklyBars"] as? Int ?? 0,
            sessionsToday: data["sessionsToday"] as? Int ?? 0,
            graceSeconds: data["graceSeconds"] as? Int ?? 5,
            isHardcoreEnabled: data["isHardcoreEnabled"] as? Bool ?? false,
            selectedAvatarID: data["selectedAvatarID"] as? String ?? MedievalAvatar.default.id,
            equippedAnvilSkinID: data["equippedAnvilSkinID"] as? String ?? CosmeticCatalog.defaultAnvilID,
            equippedFurnaceSkinID: data["equippedFurnaceSkinID"] as? String ?? CosmeticCatalog.defaultFurnaceID,
            equippedShopThemeID: data["equippedShopThemeID"] as? String ?? CosmeticCatalog.defaultThemeID,
            ownedCosmeticIDs: data["ownedCosmeticIDs"] as? [String] ?? UserProgress.empty.ownedCosmeticIDs,
            weekdayFocusSeconds: paddedIntArray(data["weekdayFocusSeconds"], count: 7),
            hourlySessionCounts: paddedIntArray(data["hourlySessionCounts"], count: 24),
            onboardingCompleted: data["onboardingCompleted"] as? Bool ?? false,
            trialStartedAt: trialStartedAt,
            hasUnlockedHardcore: data["hasUnlockedHardcore"] as? Bool ?? false,
            notificationsEnabled: data["notificationsEnabled"] as? Bool ?? false,
            usesAvatarAsProfilePhoto: data["usesAvatarAsProfilePhoto"] as? Bool ?? false
        )
    }

    private func paddedIntArray(_ raw: Any?, count: Int) -> [Int] {
        let values: [Int]
        if let ints = raw as? [Int] {
            values = ints
        } else if let numbers = raw as? [NSNumber] {
            values = numbers.map(\.intValue)
        } else {
            values = []
        }
        var result = Array(repeating: 0, count: count)
        for (index, value) in values.prefix(count).enumerated() {
            result[index] = value
        }
        return result
    }
    #endif

    private func merge(local: UserProgress, remote: UserProgress) -> UserProgress {
        func maxArray(_ a: [Int], _ b: [Int]) -> [Int] {
            let size = max(a.count, b.count)
            return (0..<size).map { index in
                max(index < a.count ? a[index] : 0, index < b.count ? b[index] : 0)
            }
        }

        var merged = UserProgress(
            forgedBars: max(local.forgedBars, remote.forgedBars),
            ownedCollectibles: local.ownedCollectibles.count >= remote.ownedCollectibles.count
                ? local.ownedCollectibles
                : remote.ownedCollectibles,
            totalSessions: max(local.totalSessions, remote.totalSessions),
            successfulSessions: max(local.successfulSessions, remote.successfulSessions),
            failedSessions: max(local.failedSessions, remote.failedSessions),
            totalFocusSeconds: max(local.totalFocusSeconds, remote.totalFocusSeconds),
            unfulfilledFocusSeconds: max(local.unfulfilledFocusSeconds, remote.unfulfilledFocusSeconds),
            currentStreak: max(local.currentStreak, remote.currentStreak),
            bestStreak: max(local.bestStreak, remote.bestStreak),
            displayName: remote.displayName.isEmpty ? local.displayName : remote.displayName,
            dailyGoalMinutes: remote.dailyGoalMinutes > 0 ? remote.dailyGoalMinutes : local.dailyGoalMinutes,
            dailyFocusSeconds: max(local.dailyFocusSeconds, remote.dailyFocusSeconds),
            dayOfYear: max(local.dayOfYear, remote.dayOfYear),
            dayCalendarYear: max(local.dayCalendarYear, remote.dayCalendarYear),
            weeklyGoalMinutes: remote.weeklyGoalMinutes > 0 ? remote.weeklyGoalMinutes : local.weeklyGoalMinutes,
            weeklyFocusSeconds: max(local.weeklyFocusSeconds, remote.weeklyFocusSeconds),
            weekOfYear: max(local.weekOfYear, remote.weekOfYear),
            calendarYear: max(local.calendarYear, remote.calendarYear),
            gems: max(local.gems, remote.gems),
            lifetimeBars: max(local.lifetimeBars, remote.lifetimeBars),
            weeklyBars: max(local.weeklyBars, remote.weeklyBars),
            sessionsToday: max(local.sessionsToday, remote.sessionsToday),
            graceSeconds: local.graceSeconds,
            isHardcoreEnabled: local.isHardcoreEnabled || remote.isHardcoreEnabled,
            selectedAvatarID: local.selectedAvatarID,
            equippedAnvilSkinID: local.equippedAnvilSkinID,
            equippedFurnaceSkinID: local.equippedFurnaceSkinID,
            equippedShopThemeID: local.equippedShopThemeID,
            ownedCosmeticIDs: Array(Set(local.ownedCosmeticIDs + remote.ownedCosmeticIDs)),
            weekdayFocusSeconds: maxArray(local.weekdayFocusSeconds, remote.weekdayFocusSeconds),
            hourlySessionCounts: maxArray(local.hourlySessionCounts, remote.hourlySessionCounts),
            onboardingCompleted: local.onboardingCompleted || remote.onboardingCompleted,
            trialStartedAt: [local.trialStartedAt, remote.trialStartedAt].compactMap { $0 }.min(),
            hasUnlockedHardcore: local.hasUnlockedHardcore || remote.hasUnlockedHardcore,
            notificationsEnabled: local.notificationsEnabled || remote.notificationsEnabled,
            usesAvatarAsProfilePhoto: local.usesAvatarAsProfilePhoto
        )
        merged.rollPeriodsIfNeeded()
        return merged
    }
}

enum AuthFlowError: LocalizedError {
    case firebaseNotConfigured
    case invalidInput
    case googlePresentationFailed
    case googleTokenMissing
    case appleTokenMissing
    case canceled
    case requiresRecentLogin
    case notLoggedIn

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase não configurado. Adicione o GoogleService-Info.plist."
        case .invalidInput:
            return "Preencha todos os campos corretamente."
        case .googlePresentationFailed:
            return "Não foi possível abrir a tela de login do Google."
        case .googleTokenMissing:
            return "Não foi possível obter o token do Google."
        case .appleTokenMissing:
            return "Não foi possível concluir o login com a Apple."
        case .canceled:
            return nil
        case .requiresRecentLogin:
            return "Entre de novo na conta e tente excluir em seguida. A Apple exige uma sessão recente."
        case .notLoggedIn:
            return "Entre na conta para poder excluí-la."
        }
    }
}
