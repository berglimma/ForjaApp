import FirebaseCore
import SwiftUI

@main
struct ForjaAppApp: App {
    @StateObject private var inventoryManager = InventoryManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var entitlements = EntitlementStore.shared

    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            GoogleSignInService.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(inventoryManager)
                .environmentObject(firebaseManager)
                .environmentObject(storeManager)
                .environmentObject(entitlements)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    _ = GoogleSignInService.handleURL(url)
                }
                .onAppear {
                    NotificationScheduler.reschedule(for: inventoryManager.progress)
                }
        }
    }
}
