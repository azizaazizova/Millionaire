import SwiftUI

struct ResultView: View {
    let persistence: PersistenceService
    let prize: Int
    let didWin: Bool
    let cashedOut: Bool
    let level: Int
    
    @Environment(\.dismiss) var dismiss
    @State private var animatePrize = false
    @State private var startNewGame = false
    
    var body: some View {
        ZStack {
            MillionaireBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Лого с наложением
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .offset(y: 20)
                    .padding(.top, 16)
                
                Text(resultTitle)
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                
                // Добавляем текст уровня
                Text("Level \(level)")
                    .font(.title3)
                    .foregroundColor(.gray.opacity(0.9))
                
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
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
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
            return .green                // победа → зелёный
        } else if cashedOut {
            return Color.orange           // забрал деньги → золотой/оранжевый
        } else {
            return Color(red: 0.7, green: 0, blue: 0) // проигрыш → красный
        }
    }
}
