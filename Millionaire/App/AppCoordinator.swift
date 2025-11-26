import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    @Published var path: [Route] = []
    @Published var startRoute: Route = .splash

    func goToHome() { path = []; startRoute = .home }
    func startNewGame() { path = []; startRoute = .game }
    func continueGame() { path = []; startRoute = .game }
    func finishGame(wonAmount: Int) {
        path = []; startRoute = .result(wonAmount: wonAmount)
    }
}
