//
//  StoreManager.swift
//  ForjaApp
//

import Foundation
import StoreKit
import Combine

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?
    @Published private(set) var isSubscribed = false
    @Published private(set) var hasHardcoreUnlock = false

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { await listenForTransactions() }
        Task { await refresh() }
    }

    var monthlyProduct: Product? { products.first { $0.id == StoreProductID.monthly } }
    var yearlyProduct: Product? { products.first { $0.id == StoreProductID.yearly } }

    func gemProduct(id: String) -> Product? {
        products.first { $0.id == id }
    }

    func product(id: String) -> Product? {
        products.first { $0.id == id }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Set(StoreProductID.all)).sorted {
                $0.displayName < $1.displayName
            }
            await updateEntitlements()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await apply(transaction)
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await updateEntitlements()
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            if let transaction = try? checkVerified(update) {
                await apply(transaction)
                await transaction.finish()
            }
        }
    }

    private func updateEntitlements() async {
        var ids: Set<String> = []
        var subscribed = false
        var hardcore = false

        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(entitlement) else { continue }
            ids.insert(transaction.productID)
            if StoreProductID.subscriptionIDs.contains(transaction.productID) {
                subscribed = true
            }
            if transaction.productID == StoreProductID.hardcore {
                hardcore = true
            }
        }

        purchasedProductIDs = ids
        isSubscribed = subscribed
        hasHardcoreUnlock = hardcore
        EntitlementStore.shared.applyStoreKit(isSubscribed: subscribed, hasHardcore: hardcore)
    }

    private func apply(_ transaction: Transaction) async {
        if StoreProductID.gemIDs.contains(transaction.productID) {
            InventoryManager.shared.addGems(StoreProductID.gemAmount(for: transaction.productID))
        } else if transaction.productID == StoreProductID.packHalloween {
            InventoryManager.shared.unlockSeasonalPack(.halloween)
        } else if transaction.productID == StoreProductID.packNatal {
            InventoryManager.shared.unlockSeasonalPack(.natal)
        } else if transaction.productID == StoreProductID.hardcore {
            InventoryManager.shared.unlockHardcore()
        }
        await updateEntitlements()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
