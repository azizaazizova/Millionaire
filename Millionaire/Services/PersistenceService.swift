import Foundation

struct SavedGame: Codable {
    let levelIndex: Int
    let wonAmount: Int
    let question: Question
}

final class PersistenceService {
    private let key = "millionaire.savedGame"

    func save(_ game: SavedGame?) {
        guard let game else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        let data = try? JSONEncoder().encode(game)
        UserDefaults.standard.set(data, forKey: key)
    }

    func load() -> SavedGame? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SavedGame.self, from: data)
    }
}
