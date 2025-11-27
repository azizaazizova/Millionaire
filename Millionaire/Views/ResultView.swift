import SwiftUI

struct ResultView: View {
    let persistence: PersistenceService

    var body: some View {
        ZStack {
            // Фон через модификатор
            Color.clear.millionaireBackground()

            VStack(spacing: 24) {
                Text("Игра завершена")
                    .font(.title).bold()
                    .foregroundColor(.white)

                Text("Ваш приз: $1000")
                    .font(.title2)
                    .foregroundColor(.yellow)

                NavigationLink(destination: HomeView(persistence: persistence)) {
                    BrandButton(title: "На главную")
                }
            }
            .padding()
        }
    }
}
