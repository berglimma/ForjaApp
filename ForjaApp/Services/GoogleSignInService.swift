//
//  GoogleSignInService.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import Foundation
import UIKit

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(FirebaseCore)
import FirebaseCore
#endif

enum GoogleSignInService {
    @MainActor
    static func configure() {
        #if canImport(GoogleSignIn) && canImport(FirebaseCore)
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        #endif
    }

    @MainActor
    static func signIn() async throws {
        #if canImport(GoogleSignIn) && canImport(FirebaseAuth)
        guard let presenting = rootViewController else {
            throw AuthFlowError.googlePresentationFailed
        }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AuthFlowError.googleTokenMissing
        }

        let accessToken = signInResult.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let localProgress = InventoryManager.shared.progress

        if let user = Auth.auth().currentUser, user.isAnonymous {
            let result = try await user.link(with: credential)
            try await applyGoogleProfile(from: result.user, fallbackName: signInResult.user.profile?.name)
        } else {
            _ = try await Auth.auth().signIn(with: credential)
            try await applyGoogleProfile(from: Auth.auth().currentUser, fallbackName: signInResult.user.profile?.name)
        }

        var progress = localProgress
        if let name = Auth.auth().currentUser?.displayName, !name.isEmpty {
            progress.displayName = name
        }
        InventoryManager.shared.applyRemoteProgress(progress)
        await FirebaseManager.shared.syncProgressAfterAuth()
        #else
        throw AuthFlowError.firebaseNotConfigured
        #endif
    }

    @MainActor
    static func signOutIfNeeded() {
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
    }

    @MainActor
    static func handleURL(_ url: URL) -> Bool {
        #if canImport(GoogleSignIn)
        return GIDSignIn.sharedInstance.handle(url)
        #else
        return false
        #endif
    }

    #if canImport(FirebaseAuth)
    @MainActor
    private static func applyGoogleProfile(from user: User?, fallbackName: String?) async throws {
        guard let user else { return }
        let name = user.displayName ?? fallbackName
        guard let name, !name.isEmpty else { return }

        if user.displayName == nil || user.displayName?.isEmpty == true {
            let change = user.createProfileChangeRequest()
            change.displayName = name
            try await change.commitChanges()
        }
        InventoryManager.shared.updateDisplayName(name)
    }
    #endif

    @MainActor
    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .topMostViewController
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let navigation = self as? UINavigationController, let visible = navigation.visibleViewController {
            return visible.topMostViewController
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMostViewController
        }
        return self
    }
}
