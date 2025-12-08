import SwiftUI

struct ResultView: View {
    let persistence: PersistenceService
    let prize: Int
    let didWin: Bool       // победа — дошёл до конца
    let cashedOut: Bool    // вышел по кнопке "Забрать деньги"

    @Environment(\.dismiss) var dismiss
    @State private var animatePrize = false
    @State private var startNewGame = false

    var body: some View {
        ZStack {
            Color.clear.millionaireBackground().ignoresSafeArea()

            VStack(spacing: 32) {
                Text(resultTitle)
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)

                Text("Ваш приз: $\(prize)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(prizeColor)
                    .scaleEffect(animatePrize ? 1.1 : 0.8)
                    .opacity(animatePrize ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: animatePrize)
                    .onAppear { animatePrize = true }

                VStack(spacing: 16) {
                    Button {
                        persistence.save(nil)
                        startNewGame = true
                    } label: {
                        BrandButton(title: "Играть снова")
                    }

                    Button {
                        persistence.save(nil)
                        dismiss()
                    } label: {
                        BrandButton(title: "На главную")
                    }
                }
            }
            .padding()
        }
        //  убираем кнопку назад
        .navigationBarBackButtonHidden(true)
        // если нужен переход на новую игру
        .navigationDestination(isPresented: $startNewGame) {
            GameView(persistence: persistence)
        }
    }

    private var resultTitle: String {
        if didWin {
            return "Поздравляем! Вы выиграли!"
        } else if cashedOut {
            return "Вы забрали деньги!"
        } else {
            return "Игра завершена"
        }
    }

    private var prizeColor: Color {
        if didWin {
            return .green
        } else if cashedOut {
            return .blue
        } else {
            return .yellow
        }
    }
}
