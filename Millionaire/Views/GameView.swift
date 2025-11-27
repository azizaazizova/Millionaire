import SwiftUI

struct GameView: View {
    let persistence: PersistenceService

    var body: some View {
        VStack(spacing: 20) {
            millionaireBackground()
            Text("Игра началась!")
                .font(.title)
                .foregroundColor(.white)

            NavigationLink(destination: ResultView(persistence: persistence)) {
                BrandButton(title: "Завершить игру")
            }
        }
        .padding()
    }
    
}
