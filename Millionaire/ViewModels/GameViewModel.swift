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
    @Published var secondChanceActive: Bool = false
    @Published var isFinished: Bool = false

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.questions = QuestionService.loadQuestions()

        if questions.isEmpty {
            // Нет вопросов — завершаем игру безопасно
            isFinished = true
            currentIndex = 0
            return
        }

        // Загружаем сохранённую игру и НОРМАЛИЗУЕМ индекс
        if let saved = persistence.load() {
            let safeIndex = max(0, min(saved.levelIndex, questions.count - 1))
            self.currentIndex = safeIndex
            self.wonAmount = saved.wonAmount
        }
    }

    // Безопасный доступ к текущему вопросу
    var currentQuestion: Question {
        if questions.indices.contains(currentIndex) {
            return questions[currentIndex]
        } else {
            // При несоответствии индекса возвращаем первый вопрос (или делаем assert в дев-сборках)
            return questions.first!
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.goToNextQuestion()
            }
        } else if secondChanceActive {
            // сбрасываем право на ошибку
            secondChanceActive = false
            isCorrect = nil
        } else {
            finishGame()
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
            finishGame()
        }
    }

    func finishGame() {
        isFinished = true
        saveProgress()
    }

    func timeExpired() {
        finishGame()
    }

    // MARK: - Подсказки
    func useFiftyFifty() {
        guard !isGameFinished, hiddenIndices.isEmpty else { return }
        let correct = currentQuestion.correctIndex
        let wrong = Set(currentQuestion.answers.indices).subtracting([correct])
        hiddenIndices = Set(Array(wrong.shuffled().prefix(2)))
    }

    func simulateCall() {
        guard !isGameFinished else { return }
        let correct = currentQuestion.correctIndex
        let chance = Int.random(in: 1...100)
        let picked = chance <= 70 ? correct : currentQuestion.answers.indices.filter { $0 != correct }.randomElement()!
        print("📞 Друг думает, что это: \(currentQuestion.answers[picked])")
    }

    func simulateAudience() -> [Int: Int] {
        guard !isGameFinished else { return [:] }
        let correct = currentQuestion.correctIndex
        var percentages: [Int: Int] = [:]

        let correctPercent = Int.random(in: 40...60)
        percentages[correct] = correctPercent

        let remaining = 100 - correctPercent
        let wrongAnswers = currentQuestion.answers.indices.filter { $0 != correct }
        var distributed = wrongAnswers.map { _ in Int.random(in: 10...30) }

        let sum = distributed.reduce(0, +)
        for i in 0..<distributed.count {
            distributed[i] = Int(Double(distributed[i]) / Double(sum) * Double(remaining))
        }
        for (i, idx) in wrongAnswers.enumerated() {
            percentages[idx] = distributed[i]
        }
        return percentages
    }

    func useSecondChance() {
        guard !isGameFinished else { return }
        secondChanceActive = true
    }

    // MARK: - Persistence
    private func saveProgress() {
        guard questions.indices.contains(currentIndex) else { return }
        let saved = SavedGame(
            levelIndex: currentIndex,
            wonAmount: wonAmount,
            question: currentQuestion
        )
        persistence.save(saved)
    }
}
