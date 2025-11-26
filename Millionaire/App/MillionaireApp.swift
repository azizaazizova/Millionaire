import SwiftUI

@main
struct MillionaireApp: App {
    @StateObject private var coordinator = AppCoordinator()
    private let persistence = PersistenceService() // ✅ просто обычный объект

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                switch coordinator.startRoute {
                case .splash:
                    SplashView(onFinish: { coordinator.goToHome() })
                case .home:
                    HomeView(coordinator: coordinator, persistence: persistence)
                case .game:
                    GameView(coordinator: coordinator, persistence: persistence)
                case .result(let amount):
                    ResultView(coordinator: coordinator, amount: amount)
                }
            }
        }
    }
}
