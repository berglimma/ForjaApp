//
//  SocialService.swift
//  ForjaApp
//

import Foundation
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

@MainActor
final class SocialService: ObservableObject {
    static let shared = SocialService()

    @Published var currentGuild: Guild?
    @Published var currentChallenge: FocusChallenge?
    @Published var isLoading = false
    @Published var message: String?

    private init() {}

    func refresh() async {
        await fetchGuild()
        await fetchChallenge()
    }

    func createGuild(name: String) async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Faça login para criar uma guilda."
            return
        }
        isLoading = true
        defer { isLoading = false }

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            message = "O nome da guilda precisa ter pelo menos 3 letras."
            return
        }

        let code = Self.makeCode()
        let displayName = InventoryManager.shared.progress.displayName
        let weeklyBars = InventoryManager.shared.progress.weeklyBars
        let db = Firestore.firestore()
        let ref = db.collection("guilds").document()

        do {
            try await ref.setData([
                "name": trimmed,
                "joinCode": code,
                "ownerID": uid,
                "memberIDs": [uid],
                "weeklyBars": [uid: weeklyBars],
                "displayNames": [uid: displayName],
                "weekOfYear": UserProgress.weekOfYear(from: Date()),
                "calendarYear": UserProgress.calendarYear(from: Date()),
                "updatedAt": FieldValue.serverTimestamp()
            ])
            try await db.collection("users").document(uid).setData(["guildID": ref.documentID], merge: true)
            await fetchGuild()
            message = "Guilda criada. Código: \(code)"
        } catch {
            message = error.localizedDescription
        }
        #else
        message = "Firebase não configurado."
        #endif
    }

    func joinGuild(code: String) async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Faça login para entrar em uma guilda."
            return
        }
        isLoading = true
        defer { isLoading = false }

        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("guilds")
                .whereField("joinCode", isEqualTo: normalized)
                .limit(to: 1)
                .getDocuments()

            guard let doc = snapshot.documents.first else {
                message = "Nenhuma guilda com esse código."
                return
            }

            var memberIDs = doc.data()["memberIDs"] as? [String] ?? []
            if memberIDs.count >= 8 {
                message = "Essa guilda já está cheia (máx. 8 ferreiros)."
                return
            }
            if !memberIDs.contains(uid) {
                memberIDs.append(uid)
            }

            try await doc.reference.setData([
                "memberIDs": memberIDs,
                "displayNames.\(uid)": InventoryManager.shared.progress.displayName,
                "weeklyBars.\(uid)": InventoryManager.shared.progress.weeklyBars
            ], merge: true)
            try await db.collection("users").document(uid).setData(["guildID": doc.documentID], merge: true)
            await fetchGuild()
            message = "Você entrou na guilda!"
        } catch {
            message = error.localizedDescription
        }
        #else
        message = "Firebase não configurado."
        #endif
    }

    func createChallenge() async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Faça login para desafiar um amigo."
            return
        }
        isLoading = true
        defer { isLoading = false }

        let code = Self.makeCode()
        let db = Firestore.firestore()
        let ref = db.collection("challenges").document()
        let now = Date()

        do {
            try await ref.setData([
                "joinCode": code,
                "hostID": uid,
                "hostName": InventoryManager.shared.progress.displayName,
                "opponentID": NSNull(),
                "opponentName": NSNull(),
                "hostFocusSeconds": InventoryManager.shared.progress.weeklyFocusSeconds,
                "opponentFocusSeconds": 0,
                "weekOfYear": UserProgress.weekOfYear(from: now),
                "calendarYear": UserProgress.calendarYear(from: now),
                "status": FocusChallenge.Status.waiting.rawValue,
                "updatedAt": FieldValue.serverTimestamp()
            ])
            try await db.collection("users").document(uid).setData(["challengeID": ref.documentID], merge: true)
            await fetchChallenge()
            message = "Desafio criado. Código: \(code)"
        } catch {
            message = error.localizedDescription
        }
        #else
        message = "Firebase não configurado."
        #endif
    }

    func joinChallenge(code: String) async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Faça login para aceitar um desafio."
            return
        }
        isLoading = true
        defer { isLoading = false }

        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("challenges")
                .whereField("joinCode", isEqualTo: normalized)
                .limit(to: 1)
                .getDocuments()

            guard let doc = snapshot.documents.first else {
                message = "Nenhum desafio com esse código."
                return
            }

            let hostID = doc.data()["hostID"] as? String ?? ""
            if hostID == uid {
                message = "Você não pode entrar no próprio desafio."
                return
            }

            try await doc.reference.setData([
                "opponentID": uid,
                "opponentName": InventoryManager.shared.progress.displayName,
                "opponentFocusSeconds": InventoryManager.shared.progress.weeklyFocusSeconds,
                "status": FocusChallenge.Status.active.rawValue
            ], merge: true)
            try await db.collection("users").document(uid).setData(["challengeID": doc.documentID], merge: true)
            await fetchChallenge()
            message = "Desafio aceito. Que foque mais essa semana!"
        } catch {
            message = error.localizedDescription
        }
        #else
        message = "Firebase não configurado."
        #endif
    }

    func syncWeeklyTotals() async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let progress = InventoryManager.shared.progress
        let db = Firestore.firestore()

        if let guild = currentGuild {
            try? await db.collection("guilds").document(guild.id).setData([
                "weeklyBars.\(uid)": progress.weeklyBars,
                "displayNames.\(uid)": progress.displayName
            ], merge: true)
        }

        if let challenge = currentChallenge {
            let field = uid == challenge.hostID ? "hostFocusSeconds" : "opponentFocusSeconds"
            try? await db.collection("challenges").document(challenge.id).setData([
                field: progress.weeklyFocusSeconds
            ], merge: true)
        }
        #endif
    }

    private func fetchGuild() async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        do {
            let userDoc = try await db.collection("users").document(uid).getDocument()
            guard let guildID = userDoc.data()?["guildID"] as? String else {
                currentGuild = nil
                return
            }
            let snapshot = try await db.collection("guilds").document(guildID).getDocument()
            guard snapshot.exists, let data = snapshot.data() else {
                currentGuild = nil
                return
            }
            currentGuild = Guild(
                id: snapshot.documentID,
                name: data["name"] as? String ?? "Guilda",
                joinCode: data["joinCode"] as? String ?? "",
                ownerID: data["ownerID"] as? String ?? "",
                memberIDs: data["memberIDs"] as? [String] ?? [],
                weeklyBars: Self.intMap(data["weeklyBars"]),
                displayNames: data["displayNames"] as? [String: String] ?? [:]
            )
        } catch {
            message = error.localizedDescription
        }
        #endif
    }

    private func fetchChallenge() async {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        do {
            let userDoc = try await db.collection("users").document(uid).getDocument()
            guard let challengeID = userDoc.data()?["challengeID"] as? String else {
                currentChallenge = nil
                return
            }
            let snapshot = try await db.collection("challenges").document(challengeID).getDocument()
            guard snapshot.exists, let data = snapshot.data() else {
                currentChallenge = nil
                return
            }
            let statusRaw = data["status"] as? String ?? FocusChallenge.Status.waiting.rawValue
            currentChallenge = FocusChallenge(
                id: snapshot.documentID,
                joinCode: data["joinCode"] as? String ?? "",
                hostID: data["hostID"] as? String ?? "",
                hostName: data["hostName"] as? String ?? "Ferreiro",
                opponentID: data["opponentID"] as? String,
                opponentName: data["opponentName"] as? String,
                hostFocusSeconds: data["hostFocusSeconds"] as? Int ?? 0,
                opponentFocusSeconds: data["opponentFocusSeconds"] as? Int ?? 0,
                weekOfYear: data["weekOfYear"] as? Int ?? 0,
                calendarYear: data["calendarYear"] as? Int ?? 0,
                status: FocusChallenge.Status(rawValue: statusRaw) ?? .waiting
            )
        } catch {
            message = error.localizedDescription
        }
        #endif
    }

    private static func makeCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in alphabet.randomElement()! })
    }

    private static func intMap(_ raw: Any?) -> [String: Int] {
        if let ints = raw as? [String: Int] {
            return ints
        }
        if let numbers = raw as? [String: NSNumber] {
            return numbers.mapValues(\.intValue)
        }
        return [:]
    }
}
