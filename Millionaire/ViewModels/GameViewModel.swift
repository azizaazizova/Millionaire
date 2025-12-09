import Foundation
import Combine

class GameViewModel: ObservableObject {
    private let persistence: PersistenceService

    @Published var questions: [Question]
    @Published var currentIndex: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var isCorrect: Bool? = nil
    @Published var hiddenIndices: Set<Int> = []
    @Published var wonAmount: Int = 0
    @Published var guaranteedPrize: Int = 0   // несгораемая сумма
    @Published var secondChanceActive: Bool = false
    @Published var isFinished: Bool = false
    @Published var showSecondChanceAlert: Bool = false
    @Published var resetTimer: Bool = false
    @Published var autoSecondChanceActivated: Bool = false




    private let guaranteedLevels: [Int: Int] = [
        4: 1000,
        9: 32000,
        14: 1000000
    ]

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.questions = QuestionService.loadQuestions()

        if questions.isEmpty {
            isFinished = true
            currentIndex = 0
            return
        }

        if let saved = persistence.load() {
            let safeIndex = max(0, min(saved.levelIndex, questions.count - 1))
            self.currentIndex = safeIndex
            self.wonAmount = saved.wonAmount
            self.guaranteedPrize = guaranteedLevels[safeIndex] ?? 0
        }
    }

    var currentQuestion: Question {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : questions.first!
    }

    var isGameFinished: Bool {
        isFinished || questions.isEmpty
    }

    // MARK: - Логика ответов
    func selectAnswer(_ index: Int) {
        guard !isGameFinished else { return }

        selectedAnswer = index
        isCorrect = (index == currentQuestion.correctIndex)

        if isCorrect == true {
            wonAmount = currentQuestion.prize

            // фиксируем несгораемую сумму, если достигли уровня
            if let safePrize = guaranteedLevels[currentIndex] {
                guaranteedPrize = safePrize
            }

        } else if !secondChanceActive {
            secondChanceActive = true
            showSecondChanceAlert = true // триггерим алерт
            autoSecondChanceActivated = true   // сигнал в GameView

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.selectedAnswer = nil
                self.isCorrect = nil
            }
        } else {
            // если подсказка уже была использована — завершаем игру
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.finishWithGuaranteedPrize()
            }
        }
    }

    func goToNextQuestion() {
        guard !isGameFinished else { return }
        selectedAnswer = nil
        isCorrect = nil
        hiddenIndices = []

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            saveProgress()
        } else {
            wonAmount = questions.last?.prize ?? guaranteedPrize
            finishGame()
        }
    }

    func finishGame() {
        if wonAmount == 0 {
            let fallback = guaranteedPrize > 0 ? guaranteedPrize :
                guaranteedLevels
                    .filter { $0.key <= currentIndex }
                    .sorted { $0.key > $1.key }
                    .first?.value ?? 0
            wonAmount = fallback
        }
        isFinished = true
        saveProgress()
    }

    func timeExpired() {
        finishGame()
    }

    func cashOut() {
        wonAmount = currentQuestion.prize
        finishGame()
    }

    private func finishWithGuaranteedPrize() {
        let fallback = guaranteedPrize > 0 ? guaranteedPrize :
            guaranteedLevels
                .filter { $0.key <= currentIndex }
                .sorted { $0.key > $1.key }
                .first?.value ?? 0
        wonAmount = fallback
        finishGame()
    }

    // MARK: - Подсказки
    func useFiftyFifty() -> [Int] {
        guard !isGameFinished, hiddenIndices.isEmpty else { return [] }
        let correct = currentQuestion.correctIndex
        let wrong = Set(currentQuestion.answers.indices).subtracting([correct])
        hiddenIndices = Set(Array(wrong.shuffled().prefix(2)))
        return Array(hiddenIndices)
    }

    func simulateCall() -> String {
        guard !isGameFinished else { return "Игра завершена" }
        let correct = currentQuestion.correctIndex
        let chance = Int.random(in: 1...100)
        let picked = chance <= 70 ? correct : currentQuestion.answers.indices.filter { $0 != correct }.randomElement()!
        return "Друг думает, что это: \(currentQuestion.answers[picked])"
    }

    func simulateAudience() -> [(answer: String, percent: Int)] {
        guard !isGameFinished else { return [] }
        let correct = currentQuestion.correctIndex
        var percentages: [Int: Int] = [:]

        // правильный ответ получает 65–75%
        var correctPercent = Int.random(in: 65...75)
        percentages[correct] = correctPercent

        let remaining = 100 - correctPercent
        let wrongAnswers = currentQuestion.answers.indices.filter { $0 != correct }

        // распределяем остаток между неправильными
        var distributed = wrongAnswers.map { _ in Int.random(in: 5...20) }
        let sum = distributed.reduce(0, +)

        for i in 0..<distributed.count {
            distributed[i] = Int(Double(distributed[i]) / Double(sum) * Double(remaining))
        }

        // корректируем последний элемент массива distributed, чтобы сумма была ровно remaining
        let distributedSum = distributed.reduce(0, +)
        if let lastIdx = distributed.indices.last {
            distributed[lastIdx] += (remaining - distributedSum)
        }

        for (i, idx) in wrongAnswers.enumerated() {
            let noise = Int.random(in: -2...2)
            percentages[idx] = max(0, distributed[i] + noise)
        }
        if let noise = [-2, -1, 0, 1, 2].randomElement() {
            correctPercent = max(0, min(100, correctPercent + noise))
            percentages[correct] = correctPercent
        }

        let total = percentages.values.reduce(0, +)

        let fallbackKey = wrongAnswers.last ?? correct
        percentages[fallbackKey] = max(0, (percentages[fallbackKey] ?? 0) + (100 - total))

        // собираем результат в порядке исходных ответов
        return currentQuestion.answers.indices.map { idx in
            (answer: currentQuestion.answers[idx], percent: percentages[idx] ?? 0)
        }
    }


    func useSecondChance() -> String {
        guard !isGameFinished else { return "Игра завершена" }
        secondChanceActive = true
        return "Вторая попытка активирована!"
    }

    private func saveProgress() {
        guard questions.indices.contains(currentIndex) else { return }
        let saved = SavedGame(
            levelIndex: currentIndex,
            wonAmount: wonAmount,
            question: currentQuestion
        )
        persistence.save(saved)
    }

    var didWin: Bool {
        isFinished && currentIndex == questions.count - 1 && wonAmount == questions.last?.prize
    }

    var cashedOut: Bool {
        isFinished && selectedAnswer == nil && isCorrect == nil
    }
}
