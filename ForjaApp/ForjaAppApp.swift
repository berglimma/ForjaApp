import FirebaseCore
import SwiftUI

@main
struct ForjaAppApp: App {
    @StateObject private var inventoryManager = InventoryManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared

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
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    _ = GoogleSignInService.handleURL(url)
                }
        }
    }
}
