import Foundation

struct QuestionService {
    static func loadQuestions() -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Не удалось найти questions.json")
            return []
        }
        do {
            return try JSONDecoder().decode([Question].self, from: data)
        } catch {
            print("Ошибка декодирования: \(error)")
            return []
        }
    }
}
