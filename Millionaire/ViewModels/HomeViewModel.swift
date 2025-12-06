import Foundation
import Combine

class HomeViewModel: ObservableObject {
    private let persistence: PersistenceService

    @Published var canContinue: Bool = false
    @Published var lastPrize: Int = 0

    init(persistence: PersistenceService) {
        self.persistence = persistence
        refreshFromPersistence()
    }

    func refreshFromPersistence() {
        if let saved = persistence.load() {
            canContinue = true
            lastPrize = saved.wonAmount
        } else {
            canContinue = false
            lastPrize = 0
        }
    }
}
