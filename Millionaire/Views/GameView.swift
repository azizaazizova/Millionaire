import SwiftUI
import Combine

struct GameView: View {
    let persistence: PersistenceService
    @StateObject private var viewModel: GameViewModel

    @State private var timeRemaining = 30
    @State private var timerRunning = true
    @State private var showProgressOverlay = false

    @State private var hintUsed = false
    @State private var callUsed = false
    @State private var audienceUsed = false
    @State private var secondChanceUsed = false

    @State private var backgroundStyle: AnyView = AnyView(Color.clear.millionaireBackground())

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
                        QuestionHeaderView(
                            timeRemaining: timeRemaining,
                            question: viewModel.currentQuestion.question
                        )

                        Spacer(minLength: 10)

                        VStack(spacing: 18) {
                            AnswersBlockView(
                                answers: viewModel.currentQuestion.answers,
                                hiddenIndices: viewModel.hiddenIndices,
                                selectedAnswer: viewModel.selectedAnswer,
                                isCorrect: viewModel.isCorrect,
                                onSelect: { index in
                                    viewModel.selectAnswer(index)
                                    timerRunning = false
                                }
                            )

                            HintsBlockView(
                                hintUsed: $hintUsed,
                                callUsed: $callUsed,
                                audienceUsed: $audienceUsed,
                                secondChanceUsed: $secondChanceUsed,
                                onFiftyFifty: {
                                    _ = viewModel.useFiftyFifty()
                                    hintUsed = true
                                },
                                onCall: {
                                    callMessage = viewModel.simulateCall()
                                    callUsed = true
                                    showCallAlert = true
                                },
                                onAudience: {
                                    audienceResult = viewModel.simulateAudience()
                                    audienceUsed = true
                                    showAudienceAlert = true
                                },
                                onSecondChance: {
                                    secondChanceMessage = viewModel.useSecondChance()
                                    secondChanceUsed = true
                                    showSecondChanceAlert = true
                                }
                            )
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                } else {
                    ResultView(
                        persistence: persistence,
                        prize: viewModel.wonAmount,
                        didWin: viewModel.didWin,
                        cashedOut: viewModel.cashedOut
                    )
                }

                if showProgressOverlay {
                    LevelProgressView(
                        currentLevel: viewModel.currentIndex,
                        onCashOut: {
                            timerRunning = false
                            viewModel.cashOut()
                        }
                    )
                    .transition(.opacity)
                    .onTapGesture {
                        showProgressOverlay = false
                        if !viewModel.isGameFinished {
                            timerRunning = true   // перезапуск при ручном закрытии
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showProgressOverlay = false
                            if !viewModel.isGameFinished {
                                timerRunning = true   // перезапуск после автозакрытия
                            }
                        }
                    }
                }
            }
            .toolbar {
                if !viewModel.isGameFinished && !showProgressOverlay {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showProgressOverlay = true
                            timerRunning = false
                        } label: {
                            Image("levels")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        ToolbarTitleView(
                            index: viewModel.currentIndex,
                            prize: viewModel.currentQuestion.prize
                        )
                    }
                }
            }
            // алерты для подсказок
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
            // 🔥 Таймер и его перезапуск
            .onChange(of: viewModel.isCorrect) { _, newValue in
                if newValue == true {
                    showProgressOverlay = true
                }
            }
            .onChange(of: viewModel.currentIndex) { _, _ in
                timeRemaining = 30
                timerRunning = true
            }
            .onChange(of: viewModel.isGameFinished) { _, finished in
                if finished {
                    timerRunning = false
                }
            }
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                guard timerRunning else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
                if timeRemaining == 0 {
                    timerRunning = false
                    viewModel.timeExpired()
                }
            }
        }
    }
}

// MARK: - Вынесенные под‑вью

struct QuestionHeaderView: View {
    let timeRemaining: Int
    let question: String

    var body: some View {
        VStack(spacing: 30) {
            TimerView(seconds: timeRemaining)
                .frame(width: 84, height: 64)

            Text(question)
                .font(.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct AnswersBlockView: View {
    let answers: [String]
    let hiddenIndices: Set<Int>
    let selectedAnswer: Int?
    let isCorrect: Bool?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(answers.indices, id: \.self) { index in
                if !hiddenIndices.contains(index) {
                    AnswerButtonView(
                        index: index,
                        text: answers[index],
                        selected: selectedAnswer,
                        isCorrect: isCorrect,
                        action: { onSelect(index) }
                    )
                }
            }
        }
    }
}

struct HintsBlockView: View {
    @Binding var hintUsed: Bool
    @Binding var callUsed: Bool
    @Binding var audienceUsed: Bool
    @Binding var secondChanceUsed: Bool

    let onFiftyFifty: () -> Void
    let onCall: () -> Void
    let onAudience: () -> Void
    let onSecondChance: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            OvalHintButton(title: "50:50", disabled: hintUsed) {
                onFiftyFifty()
                hintUsed = true
            }
            OvalHintButton(title: "", systemImage: "phone.fill", disabled: callUsed) {
                onCall()
                callUsed = true
            }
            OvalHintButton(title: "", systemImage: "person.3.fill", disabled: audienceUsed) {
                onAudience()
                audienceUsed = true
            }
            OvalHintButton(title: "", systemImage: "heart.fill", disabled: secondChanceUsed) {
                onSecondChance()
                secondChanceUsed = true
            }
        }
    }
}

struct ToolbarTitleView: View {
    let index: Int
    let prize: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("ВОПРОС #\(index + 1)")
                .font(.headline)
                .foregroundColor(.white)

            Text("$\(prize)")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
        }
    }
}
