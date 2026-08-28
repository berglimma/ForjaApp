//
//  AppleSignInService.swift
//  ForjaApp
//

import AuthenticationServices
import CryptoKit
import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

enum AppleSignInService {
    private static var currentNonce: String?

    static func prepare(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    @MainActor
    static func handle(_ result: Result<ASAuthorization, Error>) async throws {
        switch result {
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                throw AuthFlowError.canceled
            }
            throw error
        case .success(let authorization):
            #if canImport(FirebaseAuth)
            try await finish(authorization)
            #else
            throw AuthFlowError.firebaseNotConfigured
            #endif
        }
    }

    #if canImport(FirebaseAuth)
    @MainActor
    private static func finish(_ authorization: ASAuthorization) async throws {
        guard FirebaseManager.shared.isConfigured else {
            throw AuthFlowError.firebaseNotConfigured
        }
        guard
            let appleID = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleID.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else {
            throw AuthFlowError.appleTokenMissing
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleID.fullName
        )
        let localProgress = InventoryManager.shared.progress
        let appleName = formattedName(appleID.fullName)

        do {
            if let user = Auth.auth().currentUser, user.isAnonymous {
                let result = try await user.link(with: credential)
                try await applyProfile(from: result.user, fallbackName: appleName)
            } else {
                let result = try await Auth.auth().signIn(with: credential)
                try await applyProfile(from: result.user, fallbackName: appleName)
            }
        } catch {
            let nsError = error as NSError
            if nsError.domain == AuthErrorDomain,
               nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue
                || nsError.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue
            {
                let result = try await Auth.auth().signIn(with: credential)
                try await applyProfile(from: result.user, fallbackName: appleName)
            } else {
                throw error
            }
        }

        var progress = localProgress
        if let name = Auth.auth().currentUser?.displayName, !name.isEmpty {
            progress.displayName = name
        } else if let appleName, !appleName.isEmpty {
            progress.displayName = appleName
        }
        InventoryManager.shared.applyRemoteProgress(progress)
        await FirebaseManager.shared.syncProgressAfterAuth()
        currentNonce = nil
    }

    @MainActor
    private static func applyProfile(from user: User, fallbackName: String?) async throws {
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

    private static func formattedName(_ components: PersonNameComponents?) -> String? {
        guard let components else { return nil }
        let formatted = PersonNameComponentsFormatter().string(from: components)
        return formatted.isEmpty ? nil : formatted
    }

    private static func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        precondition(status == errSecSuccess)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
