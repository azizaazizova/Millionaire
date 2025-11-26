import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var canContinue: Bool = false
    @Published var lastPrize: Int = 0

    private let persistence: PersistenceService

    init(persistence: PersistenceService) {
        self.persistence = persistence
        if let saved = persistence.load() {
            canContinue = true
            lastPrize = saved.wonAmount
        }
    }
}
