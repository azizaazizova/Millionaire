import SwiftUI

struct HomeView: View {
    let persistence: PersistenceService
    @StateObject private var vm: HomeViewModel

    init(persistence: PersistenceService) {
        self.persistence = persistence
        _vm = StateObject(wrappedValue: HomeViewModel(persistence: persistence))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                Spacer(minLength: 40)

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 280)

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

                NavigationLink(destination: GameView(persistence: persistence)) {
                    BrandButton(title: "Новая игра")
                }


                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)

            // 🔘 Кнопка "?"
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
    }
}

#Preview {
    HomeView(persistence: PersistenceService())
}
