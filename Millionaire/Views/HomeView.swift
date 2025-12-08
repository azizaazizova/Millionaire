import SwiftUI

struct HomeView: View {
    let persistence: PersistenceService
    @StateObject private var vm: HomeViewModel

    init(persistence: PersistenceService) {
        self.persistence = persistence
        _vm = StateObject(wrappedValue: HomeViewModel(persistence: persistence))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 18) {
                    Spacer(minLength: 40)

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 195, height: 195)

                    Text("Кто хочет стать миллионером?")
                        .font(.title).bold()
                        .foregroundColor(.white)

                    if vm.canContinue {
                        Text("Приз: $\(vm.lastPrize)")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        NavigationLink(destination: GameView(persistence: persistence)) {
                            BrandButton(title: "Продолжить игру")
                        }
                    }

                    // Новая игра — очищаем сохранение
                    NavigationLink(destination: GameView(persistence: persistence)) {
                        BrandButton(title: "Новая игра")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        persistence.save(nil)   // сброс прогресса
                        vm.refreshFromPersistence()
                    })

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)

                NavigationLink(destination: HelpView()) {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
            .millionaireBackground()
            .onAppear {
                vm.refreshFromPersistence()
            }
        }
    }
}

#Preview {
    HomeView(persistence: PersistenceService())
}
