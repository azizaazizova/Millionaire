import Foundation
import Combine

final class GameViewModel: ObservableObject {
    @Published var question: Question
    @Published var selectedIndex: Int? = nil
    @Published var phase: GamePhase = .notStarted
    @Published var highlightCorrectIndex: Int? = nil

    private let questionService: QuestionService
    private let persistence: PersistenceService
    private var levelIndex: Int = 0
    private var timeRemaining: Int = 30
    private var timerCancellable: AnyCancellable?

    init(questionService: QuestionService,
         persistence: PersistenceService,
         restored: SavedGame? = nil) {
        self.questionService = questionService
        self.persistence = persistence

        if let restored {
            levelIndex = restored.levelIndex
            question = restored.question
            phase = .asking(levelIndex: levelIndex, timeRemaining: 30)
        } else {
            question = questionService.question(for: levelIndex)
            phase = .asking(levelIndex: levelIndex, timeRemaining: 30)
        }

        startTimer()
        saveProgress()
    }

    // MARK: - Таймер
    func startTimer() {
        timerCancellable?.cancel()
        timeRemaining = 30
        phase = .asking(levelIndex: levelIndex, timeRemaining: timeRemaining)

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    self.phase = .asking(levelIndex: self.levelIndex,
                                         timeRemaining: self.timeRemaining)
                } else {
                    self.handleTimeout()
                }
            }
    }

    // MARK: - Выбор ответа
    func selectAnswer(_ index: Int) {
        guard case .asking = phase, selectedIndex == nil else { return }
        selectedIndex = index
        let correct = index == question.correctIndex
        highlightCorrectIndex = question.correctIndex
        phase = .answered(correct: correct, levelIndex: levelIndex)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.proceedAfterAnswer(correct: correct)
        }
    }

    private func handleTimeout() {
        highlightCorrectIndex = question.correctIndex
        phase = .answered(correct: false, levelIndex: levelIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.finish(withWin: false)
        }
    }

    // MARK: - Переходы
    private func proceedAfterAnswer(correct: Bool) {
        if correct {
            levelIndex += 1
            if levelIndex >= PrizeLevel.all.count {
                finish(withWin: true)
            } else {
                nextQuestion()
            }
        } else {
            finish(withWin: false)
        }
    }

    private func nextQuestion() {
        selectedIndex = nil
        highlightCorrectIndex = nil
        question = questionService.question(for: levelIndex)
        startTimer()
        saveProgress()
    }

    // MARK: - Завершение игры
    private func finish(withWin: Bool) {
        timerCancellable?.cancel()
        let wonAmount: Int
        if withWin {
            wonAmount = PrizeLevel.all.last?.amount ?? 0
        } else {
            let safe = PrizeLevel.all.prefix(levelIndex)
                .last(where: { $0.safe })?.amount ?? 0
            wonAmount = safe
        }
        phase = .finished(wonAmount: wonAmount)
        persistence.save(nil) // очищаем сохранёнку
    }

    // MARK: - Сохранение прогресса
    private func saveProgress() {
        let won = PrizeLevel.all.prefix(levelIndex).last?.amount ?? 0
        let saved = SavedGame(levelIndex: levelIndex,
                              wonAmount: won,
                              question: question)
        persistence.save(saved)
    }

    // MARK: - Хелперы
    func currentPrize() -> Int {
        PrizeLevel.all.prefix(levelIndex).last?.amount ?? 0
    }

    func currentLevelIndex() -> Int {
        levelIndex
    }
}
