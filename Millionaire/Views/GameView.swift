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

    @State private var backgroundStyle: AnyView = AnyView(Color.clear.millionaireBackground())

    // состояния для алертов
    @State private var showCallAlert = false
    @State private var callMessage = ""
    @State private var showAudienceAlert = false
    @State private var audienceResult: [(answer: String, percent: Int)] = []
    @State private var showSecondChanceAlert = false
    @State private var secondChanceMessage = ""

    init(persistence: PersistenceService) {
        self.persistence = persistence
        _viewModel = StateObject(wrappedValue: GameViewModel(persistence: persistence))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundStyle.ignoresSafeArea()

                if !viewModel.isGameFinished {
                    VStack(spacing: 0) {
                        // TOP: таймер + вопрос
                        VStack(spacing: 30) {
                            TimerView(seconds: timeRemaining)
                                .frame(width: 84, height: 64)

                            Text(viewModel.currentQuestion.question)
                                .font(.title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 10)

                        // BOTTOM: ответы + подсказки
                        VStack(spacing: 12) {
                            ForEach(viewModel.currentQuestion.answers.indices, id: \.self) { index in
                                if !viewModel.hiddenIndices.contains(index) {
                                    Button {
                                        viewModel.selectAnswer(index)
                                        timerRunning = false
                                    } label: {
                                        BrandButton(
                                            title: "\(letter(for: index)): \(viewModel.currentQuestion.answers[index])",
                                            overrideColor: answerColor(for: index)
                                        )
                                    }
                                }
                            }

                            HStack(spacing: 12) {
                                OvalHintButton(title: "50:50", disabled: hintUsed) {
                                    let hidden = viewModel.useFiftyFifty()
                                    hintUsed = true
                                    // UI может подсветить скрытые ответы через hidden
                                }

                                OvalHintButton(title: "📞", disabled: callUsed) {
                                    callMessage = viewModel.simulateCall()
                                    callUsed = true
                                    showCallAlert = true
                                }

                                OvalHintButton(title: "👥", disabled: audienceUsed) {
                                    audienceResult = viewModel.simulateAudience()
                                    audienceUsed = true
                                    showAudienceAlert = true
                                }

                                OvalHintButton(title: "❤️", disabled: secondChanceUsed) {
                                    secondChanceMessage = viewModel.useSecondChance()
                                    secondChanceUsed = true
                                    showSecondChanceAlert = true
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ResultView(persistence: persistence)
                }
            }
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
            .onAppear { startTimer() }
            .onChange(of: viewModel.currentIndex) {
                timeRemaining = 30
                timerRunning = true
                startTimer()
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
            // Алерты для подсказок
            .alert("Звонок другу", isPresented: $showCallAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(callMessage)
            }
            .alert("Помощь зала", isPresented: $showAudienceAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                VStack(alignment: .leading) {
                    ForEach(audienceResult, id: \.answer) { item in
                        Text("\(item.answer): \(item.percent)%")
                    }
                }
            }
            .alert("Вторая попытка", isPresented: $showSecondChanceAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(secondChanceMessage)
            }
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard timerRunning else { timer.invalidate(); return }
            if timeRemaining > 0 { timeRemaining -= 1 }
            else { timer.invalidate(); viewModel.timeExpired() }
        }
    }

    private func answerColor(for index: Int) -> Color? {
        guard let selected = viewModel.selectedAnswer else { return nil }
        return selected == index ? (viewModel.isCorrect == true ? .green : .red) : nil
    }

    private func letter(for index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }
}
