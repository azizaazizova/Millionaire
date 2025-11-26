//import SwiftUI
//
//struct AppPreview: View {
//    @StateObject private var coordinator = AppCoordinator()
//    private let persistence = PersistenceService()
//
//    var body: some View {
//        NavigationStack(path: $coordinator.path) {
//            switch coordinator.startRoute {
//            case .splash:
//                SplashView(onFinish: { coordinator.goToHome() })
//            case .home:
//                HomeView(coordinator: coordinator, persistence: persistence)
//            case .game:
//                GameView(coordinator: coordinator, persistence: persistence)
//            case .result(let amount):
//                ResultView(coordinator: coordinator, amount: amount)
//            }
//        }
//    }
//}
//
//#Preview {
//    AppPreview()
//}
