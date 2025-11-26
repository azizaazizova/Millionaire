import SwiftUI

struct ResultView: View {
    @ObservedObject var coordinator: AppCoordinator
    let amount: Int

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()

                Text(amount > 0 ? "Поздравляем!" : "Игра окончена!")
                    .font(.title).bold().foregroundColor(.white)

                Text("$\(amount)")
                    .font(.largeTitle)
                    .foregroundColor(amount > 0 ? .green : .red)

                BrandButton(title: "Новая игра") {
                    coordinator.startNewGame()
                }

                BrandButton(title: "Главный экран", action: {
                    coordinator.goToHome()
                }, filled: false)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .millionaireBackground()
        .overlay(Color.black.opacity(0.3))
    }
}

#Preview {
    ResultView(coordinator: AppCoordinator(), amount: 15000)
}
