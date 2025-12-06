import SwiftUI
import Combine

struct GameView: View {
    let persistence: PersistenceService
    @StateObject private var viewModel: GameViewModel

    @State private var timeRemaining = 30
    @State private var timerRunning = true
    @State private var showProgress = false

    @State private var hintUsed = false
    @State private var callUsed = false
    @State private var audienceUsed = false
    @State private var secondChanceUsed = false

    // Фон хранится как состояние и обновляется только при смене вопроса
    @State private var backgroundStyle: AnyView = AnyView(Color.clear.millionaireBackground())

    init(persistence: PersistenceService) {
        self.persistence = persistence
        _viewModel = StateObject(wrappedValue: GameViewModel(persistence: persistence))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundStyle
                    .ignoresSafeArea()

                if !viewModel.isGameFinished {
                    VStack(spacing: 16) {
                        // Приз сразу под навигацией
//                        Text("$\(viewModel.currentQuestion.prize)")
//                            .font(.headline)
//                            .foregroundColor(.yellow)
//                            .frame(maxWidth: .infinity)
//                            .padding(.top, 6) // небольшой отступ от навигации

                        // Основной контент игры
                        VStack(spacing: 12) {
                            // Таймер
                            TimerView(seconds: timeRemaining)
                                .frame(width: 84, height: 64)

                            // Вопрос
                            Text(viewModel.currentQuestion.question)
                                .font(.title2).bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            // Ответы
                            ForEach(viewModel.currentQuestion.answers.indices, id: \.self) { index in
                                if !viewModel.hiddenIndices.contains(index) {
                                    Button(action: {
                                        viewModel.selectAnswer(index)
                                        timerRunning = false
                                    }) {
                                        BrandButton(
                                            title: "\(letter(for: index)): \(viewModel.currentQuestion.answers[index])",
                                            overrideColor: answerColor(for: index)
                                        )
                                    }
                                }
                            }

                            // Подсказки
                            HStack(spacing: 12) {
                                OvalHintButton(title: "50:50", disabled: hintUsed) {
                                    viewModel.useFiftyFifty()
                                    hintUsed = true
                                }

                                OvalHintButton(title: "📞", disabled: callUsed) {
                                    callUsed = true
                                    viewModel.simulateCall()
                                }

                                OvalHintButton(title: "👥", disabled: audienceUsed) {
                                    audienceUsed = true
                                    _ = viewModel.simulateAudience()
                                }

                                OvalHintButton(title: "❤️", disabled: secondChanceUsed) {
                                    secondChanceUsed = true
                                    viewModel.useSecondChance()
                                }
                            }
                            .padding(.top, 12)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ResultView(persistence: persistence)
                }
            }

            // Навигация: номер вопроса (белым цветом)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("ВОПРОС #\(viewModel.currentIndex + 1)")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("$\(viewModel.currentQuestion.prize)")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                }

                // Кнопка уровней справа
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.isGameFinished {
                        Button {
                            showProgress = true
                            timerRunning = false
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                startTimer()
            }
            .onChange(of: viewModel.currentIndex) {
                timeRemaining = 30
                timerRunning = true
                startTimer()

                // Меняем фон только при переходе на новый вопрос
                withAnimation(.easeInOut(duration: 0.5)) {
                    backgroundStyle = AnyView(Color.clear.millionaireBackground())
                }
            }
            .sheet(isPresented: $showProgress, onDismiss: {
                timerRunning = true
                startTimer()
            }) {
                LevelProgressView(currentLevel: viewModel.currentIndex)
            }
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard timerRunning else {
                timer.invalidate()
                return
            }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                viewModel.timeExpired()
            }
        }
    }

    private func answerColor(for index: Int) -> Color? {
        guard let selected = viewModel.selectedAnswer else { return nil }
        if selected == index {
            return viewModel.isCorrect == true ? .green : .red
        }
        return nil
    }

    private func letter(for index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }
}
