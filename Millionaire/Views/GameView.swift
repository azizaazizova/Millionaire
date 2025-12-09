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

                        Spacer(minLength: 30)

                        VStack(spacing: 18) {
                            AnswersBlockView(
                                answers: viewModel.currentQuestion.answers,
                                hiddenIndices: viewModel.hiddenIndices,
                                selectedAnswer: viewModel.selectedAnswer,
                                isCorrect: viewModel.isCorrect,
                                onSelect: { index in
                                    viewModel.selectAnswer(index)
                                    timerRunning = false

                                    if viewModel.isCorrect == true && !viewModel.isGameFinished {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                            showProgressOverlay = true
                                        }
                                    } else {
                                        showProgressOverlay = false
                                    }
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
                                    timeRemaining = 30
                                    timerRunning = true
                                }
                            )
                            .padding(.top, 8)

                           Spacer(minLength: 30)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                } else {
                    ResultView(
                        persistence: persistence,
                        prize: viewModel.wonAmount,
                        didWin: viewModel.didWin,
                        cashedOut: viewModel.cashedOut,
                        level: viewModel.currentIndex
                    )
                }

                LevelProgressOverlay(
                    currentLevel: viewModel.currentIndex,
                    onCashOut: {
                        timerRunning = false
                        viewModel.cashOut()
                    },
                    show: $showProgressOverlay,
                    timerRunning: $timerRunning,
                    isGameFinished: viewModel.isGameFinished,
                    isCorrect: viewModel.isCorrect,
                    onTimeExpired: {
                        viewModel.timeExpired()
                    },
                    onNextQuestion: {
                        viewModel.goToNextQuestion()
                        timeRemaining = 30
                        timerRunning = true
                    }
                )
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
            .alert("Звонок другу", isPresented: $showCallAlert) {
                Button("OK", role: .cancel) {}
            } message: { Text(callMessage) }
            .alert("Помощь зала", isPresented: $showAudienceAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                VStack(alignment: .leading) {
                    ForEach(audienceResult, id: \.answer) { item in
                        Text("\(item.answer): \(item.percent)%")
                    }
                }
            }
            .alert("Вторая попытка использована",
                   isPresented: $viewModel.showSecondChanceAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Мы активировали подсказку «Вторая попытка»")
            }
            .onChange(of: viewModel.isGameFinished) { _, finished in
                if finished {
                    timerRunning = false
                    showProgressOverlay = false
                }
            }
            .onChange(of: viewModel.autoSecondChanceActivated) { _, activated in
                if activated {
                    timeRemaining = 30
                    timerRunning = true
                    secondChanceUsed = true
                    viewModel.autoSecondChanceActivated = false
                }
            }
            .onChange(of: showProgressOverlay) { _, isShown in
                if !isShown && !viewModel.isGameFinished {
                    timerRunning = true
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
