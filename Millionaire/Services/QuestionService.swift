import Foundation

final class QuestionService {
    private var seedQuestions: [Question] = [
        Question(text: "В каком году изобрели первую посудомоечную машину?",
                 options: ["1850", "1886", "1901", "1923"],
                 correctIndex: 1),
        Question(text: "В каком году появился первый дезодорант?",
                 options: ["1888", "1902", "1912", "1920"],
                 correctIndex: 0),
    ]

    func question(for levelIndex: Int) -> Question {
        let idx = levelIndex % seedQuestions.count
        return seedQuestions[idx]
    }
}
