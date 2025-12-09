import SwiftUI

struct LevelProgressOverlay: View {
    let currentLevel: Int
    let onCashOut: () -> Void
    @Binding var show: Bool
    @Binding var timerRunning: Bool
    let isGameFinished: Bool
    let isCorrect: Bool?
    let onTimeExpired: () -> Void
    let onNextQuestion: () -> Void

    var body: some View {
        if show {
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()

                LevelProgressView(
                    currentLevel: currentLevel,
                    onCashOut: onCashOut
                )
            }
            .transition(.opacity)
            .zIndex(1)
            .onTapGesture { closeOverlay() }
            .onAppear {
                // Автоматическое закрытие через 4 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    closeOverlay()
                }
            }
        }
    }

    private func closeOverlay() {
        show = false
        guard !isGameFinished else { return }

        if isCorrect == false {
            // Неверный ответ → завершаем игру
            timerRunning = false
            onTimeExpired()
        } else if isCorrect == true {
            // Правильный ответ → переход к следующему вопросу
            onNextQuestion()
            timerRunning = true
        }
    }
}
