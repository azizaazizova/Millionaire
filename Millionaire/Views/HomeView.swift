import SwiftUI

struct HomeView: View {
    @ObservedObject var coordinator: AppCoordinator
    let persistence: PersistenceService
    @StateObject private var vm: HomeViewModel

    init(coordinator: AppCoordinator, persistence: PersistenceService) {
        self.coordinator = coordinator
        self.persistence = persistence
        _vm = StateObject(wrappedValue: HomeViewModel(persistence: persistence))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)

                Text("Кто хочет стать миллионером?")
                    .font(.title).bold()
                    .foregroundColor(.white)

                if vm.canContinue {
                    Text("Приз: $\(vm.lastPrize)")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    BrandButton(title: "Продолжить игру") {
                        coordinator.continueGame()
                    }
                }

                BrandButton(title: "Новая игра") {
                    coordinator.startNewGame()
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .millionaireBackground()
        .overlay(Color.black.opacity(0.3))
    }
}

#Preview {
    HomeView(coordinator: AppCoordinator(), persistence: PersistenceService())
}
