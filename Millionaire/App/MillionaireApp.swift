import SwiftUI
@main
struct MillionaireApp: App {
    private let persistence = PersistenceService()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSplash = false
                        }
                    }
            } else {
                NavigationStack {
                    HomeView(persistence: persistence) // ✅ root экран
                }
            }
        }
    }
}

